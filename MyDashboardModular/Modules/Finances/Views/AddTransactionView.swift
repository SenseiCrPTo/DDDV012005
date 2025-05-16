import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataStore: FinancialDataStore

    // Параметры, передаваемые при открытии sheet
    var transactionToEdit: Transaction?
    var initialTypeFromContext: TransactionType // Тип, который мог быть предустановлен (например, .income или .expense)
    var initialCategoryFromContext: String?   // Категория, которая могла быть предустановлена (например, "Накопления")
    
    var onSave: (Transaction) -> Void

    // Локальные состояния для полей формы
    @State private var amountString: String = ""
    @State private var descriptionText: String = "" // Переименовано из description
    @State private var selectedType: TransactionType
    @State private var selectedDate: Date = Date()
    @State private var selectedCategory: String = "" // Будет инициализирован в .onAppear
    @State private var selectedAccount: String = ""  // Будет инициализирован в .onAppear

    // Вычисляемые свойства
    private var isEditing: Bool { transactionToEdit != nil }
    
    // Определяем, является ли это операцией "Накопления"
    // Это свойство теперь будет вычисляться на основе dataStore, когда он доступен
    private var isFixedSavingOperation: Bool {
        // selectedCategory должен быть уже установлен из dataStore.savingCategory через onAppear
        return selectedCategory == dataStore.savingCategory && selectedType == .expense
    }

    private var categoriesForPicker: [String] {
        if isFixedSavingOperation {
            return [dataStore.savingCategory]
        } else if selectedType == .income {
            return dataStore.incomeCategories.sorted()
        } else { // .expense, но не fixed saving
            return dataStore.expenseCategories.filter { $0 != dataStore.savingCategory }.sorted()
        }
    }

    private var navigationTitleString: String {
        if isEditing {
            return "Редакт. транзакцию"
        } else {
            return selectedType == .expense ? (isFixedSavingOperation ? "Новое накопление" : "Новый расход") : "Новый доход"
        }
    }

    private var saveButtonLabel: String {
        if isEditing {
            return "Сохранить изменения"
        } else {
            return selectedType == .expense ? (isFixedSavingOperation ? "Добавить накопление" : "Добавить расход") : "Добавить доход"
        }
    }

    // Обновленный init
    init(transactionToEdit: Transaction? = nil,
         initialType: TransactionType, // Тип из TransactionSheetContext
         initialCategory: String?,   // Категория из TransactionSheetContext
         onSave: @escaping (Transaction) -> Void) {
        
        self.transactionToEdit = transactionToEdit
        self.initialTypeFromContext = initialType
        self.initialCategoryFromContext = initialCategory
        self.onSave = onSave

        // Первичная инициализация @State
        if let t = transactionToEdit {
            _amountString = State(initialValue: String(format: "%.2f", abs(t.amount)).replacingOccurrences(of: ",", with: "."))
            _descriptionText = State(initialValue: t.description)
            _selectedType = State(initialValue: t.type) // Тип не меняется при редактировании
            _selectedDate = State(initialValue: t.date)
            _selectedCategory = State(initialValue: t.category) // Будет уточнено в onAppear, если это "Накопления"
            _selectedAccount = State(initialValue: t.account)
        } else {
            _amountString = State(initialValue: "")
            _descriptionText = State(initialValue: "")
            _selectedType = State(initialValue: initialType) // Тип из контекста
            _selectedDate = State(initialValue: Date())
            // selectedCategory и selectedAccount будут установлены в .onAppear на основе dataStore
            _selectedCategory = State(initialValue: initialCategory ?? "")
            _selectedAccount = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали")) {
                    TextField("Сумма", text: $amountString)
                        .keyboardType(.decimalPad)

                    // Тип транзакции
                    Picker("Тип", selection: $selectedType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    // Запрещаем менять тип, если это редактирование или фиксированная операция накопления
                    .disabled(isEditing || (initialCategoryFromContext == dataStore.savingCategory && initialTypeFromContext == .expense) )


                    TextField("Описание", text: $descriptionText)
                    DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)

                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(categoriesForPicker, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    // Запрещаем менять категорию, если это фиксированная операция накопления
                    .disabled(isFixedSavingOperation && selectedCategory == dataStore.savingCategory)
                    .onChange(of: selectedType) { newType in
                        // При смене типа (только для НОВЫХ, НЕ накопительных транзакций)
                        guard !isEditing && !(initialCategoryFromContext == dataStore.savingCategory && initialTypeFromContext == .expense) else { return }
                        
                        if newType == .income {
                            if !dataStore.incomeCategories.contains(selectedCategory) {
                                selectedCategory = dataStore.incomeCategories.first ?? ""
                            }
                        } else { // .expense
                            let availableExpenseCategories = dataStore.expenseCategories.filter { $0 != dataStore.savingCategory }
                            if !availableExpenseCategories.contains(selectedCategory) {
                                selectedCategory = availableExpenseCategories.first ?? ""
                            }
                        }
                    }

                    Picker("Счет", selection: $selectedAccount) {
                        ForEach(dataStore.allAccountsForPicker.sorted(), id: \.self) { account in // Сортируем для порядка
                            Text(account).tag(account)
                        }
                    }
                }

                Button {
                    saveAction()
                } label: {
                    Text(saveButtonLabel)
                }
                .disabled(amountString.isEmpty || selectedCategory.isEmpty || selectedAccount.isEmpty)
            }
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .onAppear {
                // Эта логика теперь выполняется, когда dataStore точно доступен
                if let t = transactionToEdit {
                    // Для редактирования, selectedType уже установлен из t.type
                    // selectedCategory и selectedAccount также установлены из t
                    // isFixedSavingOperation вычисляется на основе текущего selectedCategory и selectedType
                } else { // Новая транзакция
                    selectedType = initialTypeFromContext // Устанавливаем тип из контекста
                    
                    if initialCategoryFromContext == dataStore.savingCategory && initialTypeFromContext == .expense {
                        selectedCategory = dataStore.savingCategory // Это операция "Накопления"
                    } else if selectedType == .income {
                        selectedCategory = initialCategoryFromContext ?? dataStore.incomeCategories.first ?? ""
                    } else { // .expense (не накопления)
                        let availableExpense = dataStore.expenseCategories.filter { $0 != dataStore.savingCategory }
                        selectedCategory = initialCategoryFromContext ?? availableExpense.first ?? ""
                    }
                    
                    if selectedAccount.isEmpty { // Устанавливаем счет по умолчанию, если еще не установлен
                         selectedAccount = dataStore.allAccountsForPicker.first ?? ""
                    }
                }
            }
        }
    }

    private func saveAction() {
        guard let amountValue = Double(amountString.replacingOccurrences(of: ",", with: ".")),
              !selectedCategory.isEmpty,
              !selectedAccount.isEmpty else {
            // TODO: Показать алерт пользователю об ошибке ввода
            print("Ошибка: Не все поля заполнены или сумма некорректна.")
            return
        }

        let finalAmount = selectedType == .expense ? -abs(amountValue) : abs(amountValue)
        // Используем descriptionText, так как description - это свойство View
        let finalDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let effectiveDescription = finalDescription.isEmpty ? (selectedCategory.isEmpty ? (selectedType == .income ? "Доход" : "Расход") : selectedCategory) : finalDescription


        let transactionToSave: Transaction
        if let existingTransaction = transactionToEdit {
            // При редактировании ID и тип не меняются (тип мог бы меняться, если бы не было isFixedSavingOperation)
            transactionToSave = Transaction(id: existingTransaction.id,
                                          date: selectedDate,
                                          description: effectiveDescription,
                                          amount: finalAmount,
                                          type: existingTransaction.type, // Тип не меняется при редактировании
                                          category: selectedCategory,
                                          account: selectedAccount)
        } else {
            transactionToSave = Transaction(date: selectedDate,
                                          description: effectiveDescription,
                                          amount: finalAmount,
                                          type: selectedType,
                                          category: selectedCategory,
                                          account: selectedAccount)
        }

        onSave(transactionToSave) // Вызываем замыкание, которое было передано (оно вызовет dataStore.add/update)
        dismiss()
    }
}

struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = FinancialDataStore.preview // Убедись, что .preview настроен

        // Пример для новой транзакции "Доход"
        AddTransactionView(
            initialType: .income,
            initialCategory: dataStore.incomeCategories.first, // Может быть nil, если категорий нет
            onSave: { transaction in print("Preview saved income: \(transaction)") }
        )
        .environmentObject(dataStore)
        .previewDisplayName("Новый Доход")

        // Пример для новой транзакции "Расход"
        AddTransactionView(
            initialType: .expense,
            initialCategory: dataStore.expenseCategories.filter{ $0 != dataStore.savingCategory }.first,
            onSave: { transaction in print("Preview saved expense: \(transaction)") }
        )
        .environmentObject(dataStore)
        .previewDisplayName("Новый Расход")

        // Пример для новой транзакции "Накопление"
        AddTransactionView(
            initialType: .expense, // Накопления - это тип "Расход"
            initialCategory: dataStore.savingCategory, // Категория "Накопления"
            onSave: { transaction in print("Preview saved saving: \(transaction)") }
        )
        .environmentObject(dataStore)
        .previewDisplayName("Новое Накопление")
        
        // Пример для редактирования (если есть транзакции в preview)
        // if let transactionToEdit = dataStore.transactions.first {
        //     AddTransactionView(
        //         transactionToEdit: transactionToEdit,
        //         initialType: transactionToEdit.type, // Тип берется из редактируемой транзакции
        //         initialCategory: transactionToEdit.category, // Категория берется из редактируемой транзакции
        //         onSave: { transaction in print("Preview updated: \(transaction)") }
        //     )
        //     .environmentObject(dataStore)
        //     .previewDisplayName("Редактирование")
        // }
    }
}
