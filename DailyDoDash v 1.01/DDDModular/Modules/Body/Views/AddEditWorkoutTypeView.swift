import SwiftUI

// Этот View предназначен для добавления/редактирования ТИПОВ тренировок (WorkoutType)
struct AddEditWorkoutTypeView: View { // <--- ИМЯ СТРУКТУРЫ ИЗМЕНЕНО
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bodyDataStore: BodyDataStore

    var workoutTypeToEdit: WorkoutType?

    @State private var name: String
    @State private var iconName: String
    // Если у WorkoutType есть другие редактируемые поля (например, цвет), добавь для них @State

    private var isEditing: Bool { workoutTypeToEdit != nil }
    private var navigationTitleString: String {
        isEditing ? "Редактировать тип" : "Новый тип тренировки"
    }

    init(workoutTypeToEdit: WorkoutType? = nil) {
        self.workoutTypeToEdit = workoutTypeToEdit
        if let type = workoutTypeToEdit {
            _name = State(initialValue: type.name)
            _iconName = State(initialValue: type.iconName ?? "figure.walk") // Иконка по умолчанию
        } else {
            _name = State(initialValue: "")
            _iconName = State(initialValue: "figure.walk") // Иконка по умолчанию для нового типа
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о типе")) {
                    TextField("Название типа", text: $name)
                    TextField("SF Symbol для иконки (опционально)", text: $iconName)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                // Здесь можно добавить другие поля для редактирования WorkoutType, если они есть
            }
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Добавить") {
                        saveWorkoutType()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveWorkoutType() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIcon = iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let finalIconName = trimmedIcon.isEmpty ? nil : trimmedIcon

        if let existingType = workoutTypeToEdit {
            var updatedType = existingType
            updatedType.name = trimmedName
            updatedType.iconName = finalIconName
            bodyDataStore.updateWorkoutType(updatedType) // Убедись, что такой метод есть в BodyDataStore
        } else {
            bodyDataStore.addWorkoutType(name: trimmedName, iconName: finalIconName) // Убедись, что такой метод есть в BodyDataStore
        }
        dismiss()
    }
}

struct AddEditWorkoutTypeView_Previews: PreviewProvider { // <--- ИМЯ PREVIEWS ИЗМЕНЕНО
    static var previews: some View {
        // Для нового типа
        AddEditWorkoutTypeView()
            .environmentObject(BodyDataStore.preview)
            .previewDisplayName("Новый тип")
        
        // Для редактирования (если workoutTypes в preview не пустой)
        // AddEditWorkoutTypeView(workoutTypeToEdit: BodyDataStore.preview.workoutTypes.first)
        //     .environmentObject(BodyDataStore.preview)
        //     .previewDisplayName("Редактирование типа")
    }
}
