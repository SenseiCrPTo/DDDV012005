import SwiftUI

// Использует WorkoutSet из Modules/Body/Models/
struct EditWorkoutSetView: View {
    @Binding var setToEdit: WorkoutSet
    @Environment(\.dismiss) var dismiss

    // Локальные состояния для текстовых полей
    @State private var repsString: String
    @State private var weightString: String
    @State private var durationString: String
    @State private var notesString: String

    // Инициализатор для установки начальных значений @State переменных
    init(set: Binding<WorkoutSet>) {
        self._setToEdit = set // Инициализация @Binding
        // Инициализация @State свойств из значений связанного WorkoutSet
        self._repsString = State(initialValue: set.wrappedValue.reps.map { String($0) } ?? "")
        self._weightString = State(initialValue: set.wrappedValue.weight.map { String(format: "%.1f", $0) } ?? "")
        self._durationString = State(initialValue: set.wrappedValue.duration.map { String(Int($0)) } ?? "")
        self._notesString = State(initialValue: set.wrappedValue.notes ?? "")
    }

    var body: some View {
        NavigationView { // Для заголовка и кнопок toolbar
            Form {
                Section("Подход \(setToEdit.setIndex)") {
                    HStack {
                        Text("Повторения:")
                        TextField("0", text: $repsString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Вес (кг):")
                        TextField("0.0", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Длительность (сек):")
                        TextField("0", text: $durationString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("Заметки") {
                    TextEditor(text: $notesString)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Изменить подход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        setToEdit.reps = Int(repsString) // Int(nil) вернет nil, что нормально
        setToEdit.weight = Double(weightString.replacingOccurrences(of: ",", with: ".")) // Double(nil) вернет nil

        if let durationInt = Int(durationString), durationInt >= 0 {
            setToEdit.duration = TimeInterval(durationInt)
        } else {
            setToEdit.duration = nil // Если строка пустая или некорректная
        }
        setToEdit.notes = notesString.isEmpty ? nil : notesString
    }
}
