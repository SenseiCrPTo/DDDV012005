import SwiftUI

struct AddEditAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: FinancialDataStore // <--- ИЗМЕНЕНО

    var accountToEdit: String?
    @State var isSavings: Bool // Для новой или для определения типа редактируемого

    @State private var accountName: String
    @State private var isSavingsAccountType: Bool // Локальное состояние для Picker/Toggle

    private var isEditing: Bool { accountToEdit != nil }

    // init(dataStore: FinancialDataStore, ...) // <--- УДАЛИТЬ dataStore из init
    init(accountToEdit: String? = nil, isSavings: Bool = false) {
        self.accountToEdit = accountToEdit
        self._isSavings = State(initialValue: isSavings) // Инициализируем из параметра
        
        _accountName = State(initialValue: accountToEdit ?? "")
        _isSavingsAccountType = State(initialValue: isSavings) // Используем переданное значение для начального состояния Toggle
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Название счета", text: $accountName)
                Toggle("Накопительный счет", isOn: $isSavingsAccountType)
            }
            .navigationTitle(isEditing ? "Редактировать счет" : "Новый счет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { /* Кнопки Отмена и Сохранить */ }
        }
    }
    // private func saveAccount() { /* Твой код, использующий dataStore */ }
}

struct AddEditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditAccountView()
            .environmentObject(FinancialDataStore.preview) // <--- ИЗМЕНЕНО
    }
}
