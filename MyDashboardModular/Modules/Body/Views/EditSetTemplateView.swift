import SwiftUI

// Это View для редактирования ОДНОГО SetTemplate
struct EditSetTemplateView: View {
    @Binding var setTemplate: SetTemplate // Передаем Binding к SetTemplate
    @Environment(\.dismiss) var dismiss

    // Локальные состояния для текстовых полей
    @State private var targetRepsString: String
    @State private var targetWeightString: String
    @State private var targetDurationString: String
    @State private var targetRestTimeString: String

    init(setTemplate: Binding<SetTemplate>) {
        self._setTemplate = setTemplate
        // Инициализация @State свойств
        self._targetRepsString = State(initialValue: setTemplate.wrappedValue.targetReps ?? "8-12") // Дефолт, если nil
        self._targetWeightString = State(initialValue: setTemplate.wrappedValue.targetWeight.map { String(format: "%.1f", $0) } ?? "")
        self._targetDurationString = State(initialValue: setTemplate.wrappedValue.targetDuration.map { String(Int($0)) } ?? "")
        self._targetRestTimeString = State(initialValue: setTemplate.wrappedValue.targetRestTime.map { String(Int($0)) } ?? "")
    }

    var body: some View {
        NavigationView { // Для заголовка и кнопок
            Form {
                Section("Параметры подхода \(setTemplate.setIndex)") {
                    TextField("Целевые повторения (напр. 8-12, AMRAP)", text: $targetRepsString)

                    HStack {
                        Text("Целевой вес (кг):")
                        TextField("0.0", text: $targetWeightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Целевая длит. (сек):")
                        TextField("0", text: $targetDurationString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Отдых после (сек):")
                        TextField("0", text: $targetRestTimeString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Редактировать подход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") { // "Готово" вместо "Сохранить", т.к. изменения применяются через @Binding
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        // Обновляем @Binding setTemplate, что приведет к обновлению в родительском View
        setTemplate.targetReps = targetRepsString.isEmpty ? nil : targetRepsString
        setTemplate.targetWeight = Double(targetWeightString.replacingOccurrences(of: ",", with: "."))

        if let durationInt = Int(targetDurationString), durationInt >= 0 {
            setTemplate.targetDuration = TimeInterval(durationInt)
        } else {
            setTemplate.targetDuration = nil
        }

        if let restInt = Int(targetRestTimeString), restInt >= 0 {
            setTemplate.targetRestTime = TimeInterval(restInt)
        } else {
            setTemplate.targetRestTime = nil
        }
    }
}
