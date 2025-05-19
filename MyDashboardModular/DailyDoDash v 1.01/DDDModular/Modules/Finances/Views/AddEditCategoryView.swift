import SwiftUI

struct AddEditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: FinancialDataStore

    var categoryToEdit: String?
    var categoryTypeForNew: TransactionType // Тип, если создается новая категория

    @State private var categoryName: String
    @State private var selectedType: TransactionType // Тип для Picker'а и сохранения

    private var isEditing: Bool { categoryToEdit != nil }

    // init больше не принимает dataStore
    init(categoryToEdit: String? = nil, categoryType: TransactionType = .income) { // categoryType теперь имеет значение по умолчанию
        self.categoryToEdit = categoryToEdit
        self.categoryTypeForNew = categoryType // Сохраняем для использования в .onAppear
        
        _categoryName = State(initialValue: categoryToEdit ?? "")
        // Инициализируем selectedType временным значением.
        // Оно будет корректно установлено в .onAppear.
        _selectedType = State(initialValue: categoryType)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название категории")) {
                    TextField("Введите название", text: $categoryName)
                }

                // Позволяем выбирать тип только если это НОВАЯ категория
                // и если это не категория "Накопления" (которая всегда расход)
                if !isEditing && categoryName.lowercased() != dataStore.savingCategory.lowercased() {
                    Section(header: Text("Тип категории")) {
                        Picker("Тип", selection: $selectedType) {
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle()) // Для наглядности
                    }
                }
            }
            .navigationTitle(isEditing ? "Редактировать категорию" : "Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveCategory()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                // Устанавливаем selectedType на основе редактируемой категории или переданного типа
                if isEditing, let catToEdit = categoryToEdit {
                    if dataStore.incomeCategories.contains(catToEdit) {
                        selectedType = .income
                    } else if dataStore.expenseCategories.contains(catToEdit) || catToEdit == dataStore.savingCategory {
                        // Категория "Накопления" обрабатывается как расход
                        selectedType = .expense
                    }
                } else if !isEditing { // Для новой категории используем categoryTypeForNew
                    selectedType = categoryTypeForNew
                }
            }
        }
    }

    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        // Проверка на дубликат перед сохранением (учитывая тип)
        let isDuplicate: Bool
        if selectedType == .income {
            isDuplicate = dataStore.incomeCategories.contains(where: { $0.caseInsensitiveCompare(trimmedName) == .orderedSame && $0 != categoryToEdit })
        } else { // .expense
            isDuplicate = (dataStore.expenseCategories.contains(where: { $0.caseInsensitiveCompare(trimmedName) == .orderedSame && $0 != categoryToEdit }) ||
                           (trimmedName.caseInsensitiveCompare(dataStore.savingCategory) == .orderedSame && categoryToEdit != dataStore.savingCategory) )
        }
        
        if isDuplicate {
            print("Категория с именем '\(trimmedName)' для типа '\(selectedType.rawValue)' уже существует.")
            // Здесь можно показать Alert пользователю
            return
        }

        if let oldName = categoryToEdit { // Редактирование
            // Тип категории при редактировании не меняется, кроме как через удаление и создание новой
            // (если только это не "Накопления", которую вообще нельзя редактировать по имени)
            if oldName.lowercased() == dataStore.savingCategory.lowercased() && trimmedName.lowercased() != dataStore.savingCategory.lowercased() {
                print("Категорию 'Накопления' нельзя переименовать.")
                return
            }
            dataStore.updateCategory(oldName: oldName, newName: trimmedName, type: selectedType)
        } else { // Создание
            if selectedType == .income {
                dataStore.addIncomeCategory(trimmedName)
            } else { // .expense
                 // Не позволяем создавать категорию с именем "Накопления", если это не она сама
                if trimmedName.lowercased() == dataStore.savingCategory.lowercased() {
                     print("Имя категории '\(dataStore.savingCategory)' зарезервировано.")
                     return
                }
                dataStore.addExpenseCategory(trimmedName)
            }
        }
        dismiss()
    }
}

struct AddEditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        // Для новой категории дохода
        AddEditCategoryView(categoryType: .income)
            .environmentObject(FinancialDataStore.preview)
            .previewDisplayName("Новый Доход")

        // Для новой категории расхода
        AddEditCategoryView(categoryType: .expense)
            .environmentObject(FinancialDataStore.preview)
            .previewDisplayName("Новый Расход")
        
        // Для редактирования существующей (пример)
        // AddEditCategoryView(categoryToEdit: FinancialDataStore.preview.incomeCategories.first ?? "Еда", categoryType: .income)
        //     .environmentObject(FinancialDataStore.preview)
        //     .previewDisplayName("Редактирование")
    }
}
