import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var taskDataStore: TaskDataStore

    @State private var newTaskTitle: String = ""
    @State private var newTaskDescription: String = ""
    @State private var selectedDueDate: Date? = nil
    @State private var showingDatePicker = false
    @State private var selectedProjectID: UUID? = TaskProject.inbox.id
    @State private var selectedGoalHorizon: GoalHorizon? = nil
    @State private var selectedColor: Color = .clear
    @State private var isImportant: Bool = false
    private let noGoalValue: String = "Обычная задача"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Задача")) {
                    TextField("Что нужно сделать?", text: $newTaskTitle)
                    // TextField("Описание (опционально)", text: $newTaskDescription, axis: .vertical).lineLimit(3...)
                }
                Section(header: Text("Детали")) {
                    Picker("Проект/Список", selection: $selectedProjectID) {
                        Text(TaskProject.inbox.name).tag(TaskProject.inbox.id as UUID?)
                        ForEach(taskDataStore.projects.filter { $0.id != TaskProject.inbox.id }) { project in
                            Text(project.name).tag(project.id as UUID?)
                        }
                    }
                    HStack {
                        Text("Срок выполнения")
                        Spacer()
                        if let date = selectedDueDate { Text(date, style: .date).foregroundColor(.blue).onTapGesture { showingDatePicker.toggle() } }
                        else { Button("Добавить дату") { selectedDueDate = Date(); showingDatePicker = true } }
                        if selectedDueDate != nil { Button { selectedDueDate = nil; showingDatePicker = false } label: { Image(systemName: "xmark.circle.fill").foregroundColor(.gray) }.padding(.leading, 5) }
                    }
                    if showingDatePicker { DatePicker("Выберите дату", selection: Binding<Date>( get: { selectedDueDate ?? Date() }, set: { selectedDueDate = $0 }), displayedComponents: [.date]).datePickerStyle(.graphical).labelsHidden() }
                    Picker("Горизонт цели", selection: $selectedGoalHorizon) {
                        Text(noGoalValue).tag(nil as GoalHorizon?)
                        ForEach(GoalHorizon.allCases) { horizon in Text(horizon.rawValue).tag(horizon as GoalHorizon?) }
                    }
                    Toggle("Важно", isOn: $isImportant)
                    ColorPicker("Цвет задачи", selection: $selectedColor, supportsOpacity: false)
                }
            }
            .navigationTitle("Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveTask() }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    private func saveTask() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines); guard !trimmedTitle.isEmpty else { return }
        let colorHex = (selectedColor == .clear || selectedColor == Color(UIColor.systemBackground)) ? nil : selectedColor.toHex()
        taskDataStore.addTask(title: trimmedTitle, description: newTaskDescription.isEmpty ? nil : newTaskDescription, dueDate: selectedDueDate, projectID: selectedProjectID, goalHorizon: selectedGoalHorizon, colorHex: colorHex, isImportant: isImportant)
        dismiss()
    }
}
struct AddTaskSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskSheet().environmentObject(TaskDataStore.preview)
    }
}
