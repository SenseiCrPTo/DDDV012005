// MyDashboardModular/Modules/Tasks/Views/TaskListMainView.swift
import SwiftUI

struct TaskListMainView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore

    @Binding var calendarSelectedDate: Date
    @Binding var activeFilter: TaskFilterOption
    @Binding var isCalendarVisible: Bool
    @Binding var showingAddTaskSheet: Bool

    private var tasksToShow: [Task] {
        taskDataStore.getTasks(for: activeFilter, on: calendarSelectedDate, forActiveView: true)
    }

    // Динамический заголовок для этого View
    private var currentNavigationTitle: String {
        if activeFilter == .byCalendar {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd") // "16 мая"
            return dateFormatter.string(from: calendarSelectedDate)
        }
        return activeFilter.displayName // "На сегодня", "На неделю" и т.д.
    }

    var body: some View {
        VStack(spacing: 0) {
            if isCalendarVisible && activeFilter == .byCalendar {
                DatePicker("Выберите дату", selection: $calendarSelectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity))
                    )
                    .onChange(of: calendarSelectedDate) { _ in /* Можно здесь сбросить isCalendarVisible = false, если нужно */ }
            }
            
            if tasksToShow.isEmpty {
                VStack {
                    Spacer()
                    Text(messageForEmptyTasks())
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(tasksToShow) { taskItem in
                        let taskBinding = self.taskBinding(for: taskItem.id)
                        NavigationLink(destination: TaskDetailView(task: taskBinding)
                                        .environmentObject(taskDataStore) // Убедитесь, что TaskDetailView это ожидает
                        ) {
                            TaskRowView(task: taskBinding)
                                .environmentObject(taskDataStore) // Убедитесь, что TaskRowView это ожидает
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle(currentNavigationTitle) // Устанавливаем заголовок для ЭТОГО View
        .navigationBarTitleDisplayMode(.inline)  // Или .large, если хотите
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Menu {
                    // Убедитесь, что TaskFilterOption.allCases и isFilterApplicableForActiveTasks работают
                    ForEach(TaskFilterOption.allCases.filter { isFilterApplicableForActiveTasks($0) }) { filterOption in
                        Button {
                            activeFilter = filterOption
                            if filterOption != .byCalendar {
                                isCalendarVisible = false
                            } else {
                                // Если выбран фильтр по календарю, и календарь был скрыт, можно его показать
                                // или оставить управление кнопкой календаря
                                // if !isCalendarVisible { isCalendarVisible = true }
                            }
                        } label: {
                            Label(filterOption.displayName, systemImage: activeFilter == filterOption ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Фильтр", systemImage: "line.3.horizontal.decrease.circle")
                        .imageScale(.large) // Делаем иконку тулбара крупнее
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if activeFilter == .byCalendar {
                    Button {
                        withAnimation { isCalendarVisible.toggle() }
                    } label: {
                        Image(systemName: isCalendarVisible ? "calendar.circle.fill" : "calendar.circle")
                            .imageScale(.large)
                    }
                }
                Button { showingAddTaskSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                }
            }
        }
    }
    
    private func messageForEmptyTasks() -> String {
        // ... (код без изменений) ...
        switch activeFilter {
        case .today:
            return "На сегодня задач нет."
        case .byCalendar:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            return "На \(dateFormatter.string(from: calendarSelectedDate)) задач нет."
        default:
            return "Нет задач по фильтру «\(activeFilter.displayName)»."
        }
    }

    private func taskBinding(for taskID: UUID) -> Binding<Task> {
        // ... (код без изменений) ...
        guard let index = taskDataStore.tasks.firstIndex(where: { $0.id == taskID }) else {
            fatalError("Task with ID \(taskID) not found in dataStore for binding in TaskListMainView.")
        }
        return $taskDataStore.tasks[index]
    }
    
    private func deleteTask(at offsets: IndexSet) {
        // ... (код без изменений) ...
        offsets.map { tasksToShow[$0].id }.forEach { idToDelete in
            taskDataStore.deleteTask(taskId: idToDelete)
        }
    }

    private func isFilterApplicableForActiveTasks(_ filter: TaskFilterOption) -> Bool {
        // ... (код без изменений) ...
        switch filter {
        case .goalsYear, .goals3Year, .goals5Year, .goals10Year:
            return false
        default:
            return true
        }
    }
}

// Preview для TaskListMainView (код без изменений из вашего предыдущего файла)
// ...
