// MyDashboardModular/Modules/Tasks/Views/CompletedTasksListView.swift
import SwiftUI

struct CompletedTasksListView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore

    // Биндинги, получаемые от TasksMiniAppView
    @Binding var calendarSelectedDate: Date
    @Binding var activeFilter: TaskFilterOption // Используем тот же фильтр, что и для активных задач
    @Binding var isCalendarVisible: Bool
    // @State private var showingClearAlert = false // Если будете добавлять кнопку очистки

    // Фильтруем выполненные задачи на основе activeFilter и calendarSelectedDate
    private var completedTasksToShow: [Task] {
        taskDataStore.getTasks(for: activeFilter, on: calendarSelectedDate, forActiveView: false) // forActiveView: false, чтобы включить выполненные
                     .filter { $0.isCompleted }
                     .sorted { // Сортируем по дате выполнения, новые вверху
                         guard let date1 = $0.completionDate else { return false } // Не должно быть nil для isCompleted = true
                         guard let date2 = $1.completionDate else { return true }
                         return date1 > date2
                     }
    }
    
    // Динамический заголовок
    private var currentNavigationTitle: String {
        if activeFilter == .byCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
            return "Выполнено: \(dateFormatter.string(from: calendarSelectedDate))"
        }
        return "Выполнено: \(activeFilter.displayName)"
    }

    var body: some View {
        VStack(spacing: 0) {
            if isCalendarVisible && activeFilter == .byCalendar { // Показываем календарь, если нужно
                DatePicker("Выберите дату", selection: $calendarSelectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.asymmetric(insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                                            removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)))
            }
            
            if completedTasksToShow.isEmpty {
                VStack {
                    Spacer()
                    Text("Нет выполненных задач по текущему фильтру.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // Для простоты используем tasksToShow напрямую, без преобразования в [Binding<Task>]
                    // Если TaskRowView требует Binding, то нужно будет использовать mapTasksToBindings
                    ForEach(completedTasksToShow) { task in
                        // Предполагаем, что TaskRowView может отображать задачу, не требуя Binding, если он только для отображения
                        // Если TaskRowView требует Binding, то нужно вернуть mapTasksToBindings
                        // let taskBinding = taskBinding(for: task.id) // Нужен будет taskBinding метод
                        NavigationLink(destination: TaskDetailView(task: taskBinding(for: task.id))) { // Передаем Binding
                            TaskRowView(task: taskBinding(for: task.id)) // TaskRowView ожидает Binding
                        }
                    }
                    .onDelete(perform: deleteTask) // Удаление выполненных задач может быть нежелательно, или иметь другую логику
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(Text(currentNavigationTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Menu {
                    // Фильтры, применимые к выполненным задачам (например, по периодам)
                    ForEach([TaskFilterOption.today, TaskFilterOption.thisWeek, TaskFilterOption.thisMonth, TaskFilterOption.byCalendar], id: \.self) { filterOption in
                        Button {
                            activeFilter = filterOption
                            if filterOption != .byCalendar {
                                isCalendarVisible = false
                            }
                        } label: {
                            Label(filterOption.displayName, systemImage: activeFilter == filterOption ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Фильтр", systemImage: "line.3.horizontal.decrease.circle").imageScale(.large)
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if activeFilter == .byCalendar {
                    Button {
                        withAnimation { isCalendarVisible.toggle() }
                    } label: {
                        Image(systemName: isCalendarVisible ? "calendar.circle.fill" : "calendar.circle").imageScale(.large)
                    }
                }
                // Можно добавить кнопку "Очистить все выполненные" с подтверждением
                // Button(role: .destructive) { /* self.showingClearAlert = true */ } label: { Image(systemName: "trash") }
            }
        }
    }

    // Нужен метод taskBinding, если TaskRowView его ожидает
    private func taskBinding(for taskID: UUID) -> Binding<Task> {
        guard let index = taskDataStore.tasks.firstIndex(where: { $0.id == taskID }) else {
            fatalError("Task with ID \(taskID) not found in dataStore for binding in CompletedTasksListView.")
        }
        return $taskDataStore.tasks[index]
    }
    
    // deleteTask должен удалять из основного массива taskDataStore.tasks
    private func deleteTask(at offsets: IndexSet) {
        offsets.map { completedTasksToShow[$0].id }.forEach { idToDelete in
            taskDataStore.deleteTask(taskId: idToDelete)
        }
    }
}

// Preview для CompletedTasksListView
struct CompletedTasksListView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject var taskDataStore = TaskDataStore.preview // Используем preview с задачами
        @State var calendarSelectedDate: Date = Date()
        @State var activeFilter: TaskFilterOption = .thisMonth // По умолчанию смотрим за месяц
        @State var isCalendarVisible: Bool = false

        init() {
            // Для превью можно отметить несколько задач как выполненные
            if let first = _taskDataStore.wrappedValue.tasks.first, !_taskDataStore.wrappedValue.tasks[0].isCompleted {
                 _taskDataStore.wrappedValue.toggleTaskCompletion(task: first)
            }
             if _taskDataStore.wrappedValue.tasks.count > 2, !_taskDataStore.wrappedValue.tasks[1].isCompleted {
                 _taskDataStore.wrappedValue.toggleTaskCompletion(task: _taskDataStore.wrappedValue.tasks[1])
            }
        }

        var body: some View {
            NavigationView {
                CompletedTasksListView(
                    calendarSelectedDate: $calendarSelectedDate,
                    activeFilter: $activeFilter,
                    isCalendarVisible: $isCalendarVisible
                )
                .environmentObject(taskDataStore)
            }
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}
