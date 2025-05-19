import SwiftUI

struct TaskDetailView: View {
    @Binding var task: Task
    @EnvironmentObject var taskDataStore: TaskDataStore
    @Environment(\.dismiss) var dismiss

    // @State для временного хранения редактируемых значений
    @State private var titleInternal: String
    @State private var descriptionInternal: String
    @State private var dueDateInternal: Date
    @State private var hasDueDateInternal: Bool
    @State private var selectedProjectIDInternal: UUID?
    @State private var selectedGoalHorizonInternal: GoalHorizon?
    @State private var selectedColorInternal: Color
    @State private var isImportantInternal: Bool
    @State private var priorityInternal: Int

    private let noGoalValue: String = "Обычная задача"

    init(task: Binding<Task>) {
        self._task = task
        // Инициализация @State из task.wrappedValue
        _titleInternal = State(initialValue: task.wrappedValue.title)
        _descriptionInternal = State(initialValue: task.wrappedValue.description ?? "")
        _hasDueDateInternal = State(initialValue: task.wrappedValue.dueDate != nil)
        _dueDateInternal = State(initialValue: task.wrappedValue.dueDate ?? Date())
        _selectedProjectIDInternal = State(initialValue: task.wrappedValue.projectID ?? TaskProject.inbox.id)
        _selectedGoalHorizonInternal = State(initialValue: task.wrappedValue.goalHorizon)
        _selectedColorInternal = State(initialValue: Color(hex: task.wrappedValue.colorHex ?? "") ?? .clear)
        _isImportantInternal = State(initialValue: task.wrappedValue.isImportant)
        _priorityInternal = State(initialValue: task.wrappedValue.priority)
    }

    var body: some View {
        Form {
            Section(header: Text("Задача")) {
                TextField("Название задачи", text: $titleInternal) // Редактируем локальное состояние
                TextField("Описание", text: $descriptionInternal, axis: .vertical).lineLimit(3...)
            }

            Section(header: Text("Детали")) {
                Picker("Проект", selection: $selectedProjectIDInternal) { // Редактируем локальное состояние
                    Text(TaskProject.inbox.name).tag(TaskProject.inbox.id as UUID?)
                    ForEach(taskDataStore.projects.filter { $0.id != TaskProject.inbox.id }) { project in
                        Text(project.name).tag(project.id as UUID?)
                    }
                }
                Toggle(isOn: $hasDueDateInternal.animation()) { Text("Установить срок") }
                if hasDueDateInternal {
                    DatePicker("Срок выполнения", selection: $dueDateInternal, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
                Picker("Горизонт цели", selection: $selectedGoalHorizonInternal) { // Редактируем локальное состояние
                    Text(noGoalValue).tag(nil as GoalHorizon?)
                    ForEach(GoalHorizon.allCases) { horizon in Text(horizon.rawValue).tag(horizon as GoalHorizon?) }
                }
                 Picker("Приоритет", selection: $priorityInternal) { // Редактируем локальное состояние
                    Text("Нет").tag(0)
                    Text("Низкий (!)").tag(1)
                    Text("Средний (!!)").tag(2)
                    Text("Высокий (!!!)").tag(3)
                }
                Toggle("Важно", isOn: $isImportantInternal) // Редактируем локальное состояние
                ColorPicker("Цвет задачи", selection: $selectedColorInternal, supportsOpacity: false) // Редактируем локальное состояние
            }

            Section { Button("Удалить задачу", role: .destructive) { deleteTask() } }
        }
        .navigationTitle("Детали задачи")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { Button("Отмена") { dismiss() } }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Готово") { saveChanges(); dismiss() }
            }
        }
        // .onAppear не нужен, если инициализация происходит в init
    }

    private func saveChanges() {
        // Обновляем оригинальную задачу через @Binding
        task.title = titleInternal
        task.description = descriptionInternal.isEmpty ? nil : descriptionInternal
        task.dueDate = hasDueDateInternal ? dueDateInternal : nil
        task.projectID = selectedProjectIDInternal
        task.goalHorizon = selectedGoalHorizonInternal
        task.colorHex = (selectedColorInternal == .clear || selectedColorInternal == Color(UIColor.systemBackground)) ? nil : selectedColorInternal.toHex()
        task.isImportant = isImportantInternal
        task.priority = priorityInternal
        
        taskDataStore.updateTask($task.wrappedValue) // Передаем сам объект Task
    }

    private func deleteTask() {
        taskDataStore.deleteTask(taskId: task.id)
        dismiss()
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var sampleTask: Task
        init() {
            if let firstTask = TaskDataStore.preview.tasks.first { _sampleTask = State(initialValue: firstTask) }
            else { _sampleTask = State(initialValue: Task(title: "Тестовая задача", projectID: TaskProject.inbox.id)) }
        }
        var body: some View { NavigationView{ TaskDetailView(task: $sampleTask) } }
    }
    static var previews: some View {
        PreviewWrapper().environmentObject(TaskDataStore.preview)
    }
}
