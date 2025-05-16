import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var dataStore: FinancialDataStore // <--- ИЗМЕНЕНО
    @State private var showingAddEditSheet = false
    @State private var categoryToEdit: String? = nil
    @State private var categoryTypeForSheet: TransactionType = .income
    @State private var categoryNameToDelete: String? = nil
    @State private var categoryTypeForDeletion: TransactionType? = nil
    @State private var showDeleteConfirmationAlert = false
    @State private var showUsageAlert = false
    
    // init(dataStore: FinancialDataStore) { ... } // <--- УДАЛИТЬ init

    var body: some View {
        List {
            Section("Доходы") { ForEach(dataStore.incomeCategories.sorted(), id: \.self) { category in categoryRow(category: category, type: .income) } } // Добавил sorted()
            Section("Расходы") { ForEach(dataStore.expenseCategories.filter { $0 != dataStore.savingCategory }.sorted(), id: \.self) { category in categoryRow(category: category, type: .expense) } } // Добавил sorted()
            Section("Накопления") { Text(dataStore.savingCategory).foregroundColor(.gray) }
        }
        .navigationTitle("Категории")
        .toolbar { /* Твой toolbar */ }
        .sheet(isPresented: $showingAddEditSheet) {
            // AddEditCategoryView должен использовать @EnvironmentObject
            AddEditCategoryView(categoryToEdit: categoryToEdit, categoryType: categoryTypeForSheet)
        }
        .alert("Удалить категорию?", isPresented: $showDeleteConfirmationAlert, presenting: (categoryNameToDelete, categoryTypeForDeletion)) { data in /* Твой код */ } message: { data in /* Твой код */ }
        .alert("Категория используется", isPresented: $showUsageAlert) { /* Твой код */ } message: { /* Твой код */ }
    }

    @ViewBuilder
    private func categoryRow(category: String, type: TransactionType) -> some View { /* Твой код */ }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoriesView()
                .environmentObject(FinancialDataStore.preview) // <--- ИЗМЕНЕНО
        }
    }
}
