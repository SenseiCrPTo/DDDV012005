import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var dataStore: FinancialDataStore // <--- ИЗМЕНЕНО
    @State private var showingAddEditSheet = false
    @State private var accountToEdit: String? = nil
    @State private var isSavingsForSheet: Bool = false
    @State private var accountNameToDeleteState: String? = nil
    @State private var isSavingsTypeForDeletionState: Bool = false
    @State private var showDeleteConfirmationAlert = false
    @State private var showUsageAlert = false

    // init(dataStore: FinancialDataStore) { ... } // <--- УДАЛИТЬ init

    var body: some View {
        List {
            Section("Обычные счета") {
                if dataStore.generalAccounts.isEmpty { Text("Нет обычных счетов").foregroundColor(.gray) }
                ForEach(dataStore.generalAccounts.sorted(), id: \.self) { account in // Добавил sorted()
                    accountRow(account: account, isSavings: false)
                }
            }
            Section("Накопительные счета") {
                if dataStore.savingsAccounts.isEmpty { Text("Нет накопительных счетов").foregroundColor(.gray) }
                ForEach(dataStore.savingsAccounts.sorted(), id: \.self) { account in // Добавил sorted()
                    accountRow(account: account, isSavings: true)
                }
            }
        }
        .navigationTitle("Счета")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.accountToEdit = nil
                    self.isSavingsForSheet = false
                    self.showingAddEditSheet = true
                } label: { Image(systemName: "plus.circle.fill") }
            }
        }
        .sheet(isPresented: $showingAddEditSheet) {
            // AddEditAccountView должен использовать @EnvironmentObject
            AddEditAccountView(accountToEdit: accountToEdit, isSavings: isSavingsForSheet)
        }
        .alert("Удалить счет?", isPresented: $showDeleteConfirmationAlert, presenting: accountNameToDeleteState) { nameToDelete in
            Button("Удалить", role: .destructive) { dataStore.deleteAccount(name: nameToDelete, isSavings: isSavingsTypeForDeletionState) }
            Button("Отмена", role: .cancel) { }
        } message: { nameToDelete in Text("Вы уверены, что хотите удалить счет '\(nameToDelete)'?") }
        .alert("Счет используется", isPresented: $showUsageAlert) { Button("OK", role: .cancel) {} }
        message: { Text("Счет '\(accountNameToDeleteState ?? "")' используется в транзакциях и не может быть удален.") }
    }

    @ViewBuilder
    private func accountRow(account: String, isSavings: Bool) -> some View {
        HStack {
            Text(account)
            Spacer()
            if isSavings { Image(systemName: "piggy.bank.fill").foregroundColor(.blue) }
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) { /* Твой код swipeActions */ }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountsView()
                .environmentObject(FinancialDataStore.preview) // <--- ИЗМЕНЕНО
        }
    }
}
