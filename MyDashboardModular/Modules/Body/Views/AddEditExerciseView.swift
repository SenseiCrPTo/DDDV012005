import SwiftUI

struct AddEditExerciseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var bodyDataStore: BodyDataStore

    var exerciseToEdit: Exercise? // nil для нового, существующий для редактирования

    @State private var name: String = ""
    @State private var description: String = ""

    private var isEditing: Bool { exerciseToEdit != nil }
    private var navigationTitle: String {
        isEditing ? "Редактировать упражнение" : "Новое упражнение"
    }

    init(bodyDataStore: BodyDataStore, exerciseToEdit: Exercise? = nil) {
        self.bodyDataStore = bodyDataStore
        self.exerciseToEdit = exerciseToEdit

        if let exercise = exerciseToEdit {
            _name = State(initialValue: exercise.name)
            _description = State(initialValue: exercise.description ?? "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название упражнения")) {
                    TextField("Например, Приседания со штангой", text: $name)
                }

                Section(header: Text("Описание (опционально)")) {
                    TextEditor(text: $description) // Используем TextEditor для многострочного ввода
                        .frame(height: 100) // Задаем примерную высоту
                }

                Button(isEditing ? "Сохранить" : "Добавить") {
                    saveChanges()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return }

        let finalDescription = trimmedDescription.isEmpty ? nil : trimmedDescription

        if let existingExercise = exerciseToEdit {
            let updatedExercise = Exercise(id: existingExercise.id, name: trimmedName, description: finalDescription)
            bodyDataStore.updateExercise(updatedExercise)
        } else {
            bodyDataStore.addExercise(name: trimmedName, description: finalDescription)
        }
        dismiss()
    }
}
