import SwiftUI

struct LogWeightView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore
    @Environment(\.dismiss) var dismiss

    @State private var weightInput: String = ""
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section("Вес") {
                    TextField("Введите вес (например, 75.5)", text: $weightInput)
                        .keyboardType(.decimalPad)
                }
                Section("Дата") {
                    DatePicker("Дата замера", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Записать вес")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if let weightValue = Double(weightInput.replacingOccurrences(of: ",", with: ".")) {
                            bodyDataStore.logWeight(kg: weightValue, date: selectedDate)
                            dismiss()
                        } else {
                            // Здесь можно добавить State переменную для отображения Alert пользователю
                            print("Ошибка ввода веса")
                        }
                    }
                    .disabled(weightInput.isEmpty)
                }
            }
        }
    }
}

struct LogWeightView_Previews: PreviewProvider {
    static var previews: some View {
        LogWeightView()
            .environmentObject(BodyDataStore.preview)
    }
}
