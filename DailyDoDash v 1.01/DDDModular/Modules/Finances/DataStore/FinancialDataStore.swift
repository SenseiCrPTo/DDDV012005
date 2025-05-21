import SwiftUI // Для @Published и ObservableObject
// import Charts // Charts не нужен в DataStore, он будет во View

// Предполагается, что структуры Transaction, TimePeriodSelection и MonthlyDataPoint
// определены в соответствующих файлах Models.
// Например:
// Modules/Finances/Models/Transaction.swift
// Shared/Models/TimePeriodSelection.swift
// Modules/Finances/Models/MonthlyDataPoint.swift (или где он у тебя используется для periodicalChartData)

class FinancialDataStore: ObservableObject {
    @Published var transactions: [Transaction] = [ // Использует Transaction из Models_Finances
        // Твои примеры транзакций остаются здесь
        Transaction(date: Calendar.current.date(byAdding: .day, value: -40, to: Date())!, description: "Старая ЗП", amount: 100000, type: .income, category: "Зарплата", account: "Карта Сбер"),
        Transaction(date: Calendar.current.date(byAdding: .day, value: -35, to: Date())!, description: "Старые Продукты", amount: -4000, type: .expense, category: "Еда", account: "Карта Альфа"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, description: "Зарплата", amount: 120000, type: .income, category: "Зарплата", account: "Карта Сбер"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, description: "Продукты", amount: -5000, type: .expense, category: "Еда", account: "Карта Альфа"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!, description: "Накопления на машину", amount: -20000, type: .expense, category: "Накопления", account: "Копилка"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, description: "Зарплата", amount: 125000, type: .income, category: "Зарплата", account: "Карта Сбер"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, description: "Ресторан", amount: -3000, type: .expense, category: "Развлечения", account: "Карта Альфа"),
        Transaction(date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, description: "Накопления на отпуск", amount: -25000, type: .expense, category: "Накопления", account: "Копилка"),
        Transaction(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, description: "Кофе сегодня", amount: -350, type: .expense, category: "Еда", account: "Карта Альфа"),
        Transaction(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, description: "Обед вчера", amount: -750, type: .expense, category: "Еда", account: "Карта Альфа"),
        Transaction(date: Date(), description: "В копилку сегодня", amount: -15000, type: .expense, category: "Накопления", account: "Копилка"),
        Transaction(date: Date(), description: "Аванс сегодня", amount: 50000, type: .income, category: "Зарплата", account: "Карта Сбер")
    ]
    @Published var incomeCategories = ["Зарплата", "Подарки", "Фриланс", "Другой доход"]
    @Published var expenseCategories = ["Еда", "Транспорт", "Жилье", "Развлечения", "Здоровье", "Одежда", "Связь", "Другой расход"]
    let savingCategory: String = "Накопления" // Это константа, не @Published, что нормально
    var allDisplayCategories: [String] { return Array(Set(incomeCategories + expenseCategories + [savingCategory])).sorted() } // Вычисляемое свойство, отлично
    
    @Published var generalAccounts = ["Наличные", "Карта Альфа", "Карта Сбер"]
    @Published var savingsAccounts = ["Копилка"]
    var allAccountsForPicker: [String] { (generalAccounts + savingsAccounts).sorted() } // Вычисляемое свойство, отлично

    @Published var selectedAnalyticsPeriod: TimePeriodSelection = .month // Использует TimePeriodSelection из Shared/Models

    // Форматтеры валют
    private var currencyFormatterGeneral: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽" // или "₸", "₴" и т.д.
        formatter.maximumFractionDigits = 0
        return formatter
    }
    private var currencyFormatterWithCents: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2 // Чтобы всегда было две цифры после запятой
        return formatter
    }

    // Вычисляемое свойство для общего баланса
    var totalBalanceString: String {
        let total = transactions.reduce(0) { $0 + $1.amount } // amount для расходов должен быть отрицательным
        return currencyFormatterWithCents.string(from: NSNumber(value: total)) ?? "0.00 ₽"
    }

    // Твои методы getDateInterval, periodicalChartData, calculateTotal и вычисляемые свойства для доходов/расходов остаются без изменений.
    // Убедись, что они корректно работают и используют @Published свойства, если от них зависят.
    func getDateInterval(for period: TimePeriodSelection, relativeTo date: Date = Date()) -> DateInterval? {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: date) // Используем начало дня для согласованности
        switch period {
        case .week:
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
                  let endOfWeekAttempt = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else { return nil }
            let endOfWeek = calendar.startOfDay(for: endOfWeekAttempt) // Конец последнего дня недели
            let endOfInterval = calendar.date(byAdding: .day, value: 1, to: endOfWeek) ?? endOfWeek.addingTimeInterval(24*60*60) // Начало следующего дня
            return DateInterval(start: startOfWeek, end: endOfInterval)
        case .month:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let endOfInterval = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return nil }
            return DateInterval(start: startOfMonth, end: endOfInterval)
        case .year:
            guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
                  let endOfInterval = calendar.date(byAdding: .year, value: 1, to: startOfYear) else { return nil }
            return DateInterval(start: startOfYear, end: endOfInterval)
        case .allTime:
            if transactions.isEmpty { return DateInterval(start: now, duration: 1) } // Минимальный интервал, если нет транзакций
            guard let firstTransactionDate = transactions.min(by: { $0.date < $1.date })?.date,
                  let lastTransactionDate = transactions.max(by: { $0.date < $1.date })?.date else { return nil }
            let startOfInterval = calendar.startOfDay(for: firstTransactionDate)
            let endOfLastDay = calendar.startOfDay(for: lastTransactionDate)
            let endOfInterval = calendar.date(byAdding: .day, value: 1, to: endOfLastDay) ?? endOfLastDay.addingTimeInterval(24*60*60)
            return DateInterval(start: startOfInterval, end: endOfInterval)
        }
    }

    var periodicalChartData: [MonthlyDataPoint] {
        guard let interval = getDateInterval(for: selectedAnalyticsPeriod) else { return [] }
        let calendar = Calendar.current
        var dataPoints: [MonthlyDataPoint] = []

        let (groupingComponent, labelFormat, groupingFormat, incrementUnit): (Calendar.Component, String, String, Calendar.Component) = {
            switch selectedAnalyticsPeriod {
            case .week: return (.day, "EE", "yyyyMMdd", .day) // EE - короткое название дня недели
            case .month: return (.day, "d", "yyyyMMdd", .day)  // d - день месяца
            case .year: return (.month, "MMM", "yyyyMM", .month) // MMM - короткое название месяца
            case .allTime: return (.month, "MMM yy", "yyyyMM", .month) // MMM yy - месяц и год
            }
        }()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU") // Убедись, что локаль соответствует ожиданиям
        dateFormatter.dateFormat = labelFormat

        let groupingDateFormatter = DateFormatter()
        groupingDateFormatter.dateFormat = groupingFormat
        
        let filteredTransactions = transactions.filter { interval.contains($0.date) }
        
        // Создаем полный набор меток для оси X в выбранном интервале
        var allPossibleLabels = [String: Date]()
        var currentDate = interval.start
        while currentDate < interval.end {
            let labelKey = dateFormatter.string(from: currentDate)
            if allPossibleLabels[labelKey] == nil { // Добавляем только уникальные метки (актуально для группировки по дню в месяце)
                 allPossibleLabels[labelKey] = currentDate
            }
            guard let nextDate = calendar.date(byAdding: incrementUnit, value: 1, to: currentDate), nextDate > currentDate else { break }
            currentDate = nextDate
        }

        let groupedTransactions: [String: [Transaction]] = Dictionary(grouping: filteredTransactions) {
            groupingDateFormatter.string(from: $0.date)
        }

        for (label, dateForLabel) in allPossibleLabels.sorted(by: { $0.value < $1.value }) {
            let groupKey = groupingDateFormatter.string(from: dateForLabel)
            let transactionsInGroup = groupedTransactions[groupKey] ?? []
            
            let income = transactionsInGroup.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expenses = abs(transactionsInGroup.filter { $0.type == .expense && $0.category != savingCategory }.reduce(0) { $0 + $1.amount })
            let savings = abs(transactionsInGroup.filter { $0.type == .expense && $0.category == savingCategory }.reduce(0) { $0 + $1.amount })
            
            // Добавляем точки, даже если значения нулевые, чтобы график был непрерывным для всех меток
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: income, type: "Доход"))
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: expenses, type: "Расход"))
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: savings, type: "Накопления"))
        }
        return dataPoints
    }
    
    private func calculateTotal(for period: TimePeriodSelection, transactionType: TransactionType? = nil, categoryFilter: String? = nil, excludingCategoryFilter: String? = nil) -> Double {
        guard let interval = getDateInterval(for: period) else { return 0.0 }
        return transactions.filter { t in
            guard interval.contains(t.date) else { return false }
            let typeMatches = (transactionType == nil || t.type == transactionType)
            let categoryMatches = (categoryFilter == nil || t.category == categoryFilter)
            let excludingCategoryMatches = (excludingCategoryFilter == nil || t.category != excludingCategoryFilter)
            return typeMatches && categoryMatches && excludingCategoryMatches
        }.reduce(0) { $0 + $1.amount } // amount для расходов УЖЕ отрицательный
    }

    var incomeForSelectedPeriod: Double { calculateTotal(for: selectedAnalyticsPeriod, transactionType: .income) }
    var expensesForSelectedPeriodValue: Double { abs(calculateTotal(for: selectedAnalyticsPeriod, transactionType: .expense, excludingCategoryFilter: savingCategory)) }
    var savingsForSelectedPeriodValue: Double { abs(calculateTotal(for: selectedAnalyticsPeriod, transactionType: .expense, categoryFilter: savingCategory)) }

    var incomeForSelectedPeriodString: String { currencyFormatterGeneral.string(from: NSNumber(value: incomeForSelectedPeriod)) ?? "0 ₽" }
    var expensesForSelectedPeriodString: String { currencyFormatterGeneral.string(from: NSNumber(value: expensesForSelectedPeriodValue)) ?? "0 ₽" }
    var savingsForSelectedPeriodString: String { currencyFormatterGeneral.string(from: NSNumber(value: savingsForSelectedPeriodValue)) ?? "0 ₽" }

    // --- Методы CRUD ---
    // objectWillChange.send() теперь не нужен, т.к. @Published var transactions сама вызовет обновление.
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0) // Или append, если сортировка по дате будет применяться всегда
        // Если нужна сортировка после добавления:
        // transactions.sort { $0.date > $1.date } // Пример сортировки по убыванию даты
    }

    func deleteTransaction(transactionId: UUID) {
        transactions.removeAll { $0.id == transactionId }
    }

    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            // Если нужна сортировка после обновления:
            // transactions.sort { $0.date > $1.date }
        }
    }

    func addIncomeCategory(_ categoryName: String) {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !incomeCategories.contains(trimmedName), !expenseCategories.contains(trimmedName), trimmedName.lowercased() != savingCategory.lowercased() else { return }
        incomeCategories.append(trimmedName)
        incomeCategories.sort()
    }

    func addExpenseCategory(_ categoryName: String) {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !expenseCategories.contains(trimmedName), !incomeCategories.contains(trimmedName), trimmedName.lowercased() != savingCategory.lowercased() else { return }
        expenseCategories.append(trimmedName)
        expenseCategories.sort()
    }

    func updateCategory(oldName: String, newName: String, type: TransactionType) {
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNewName.isEmpty, oldName != trimmedNewName else { return }
        
        let isDuplicate = (incomeCategories.contains(trimmedNewName) || expenseCategories.contains(trimmedNewName) || trimmedNewName.lowercased() == savingCategory.lowercased())
        guard !isDuplicate || oldName.lowercased() == trimmedNewName.lowercased() else { return }

        var categoryUpdated = false
        if type == .income {
            if let index = incomeCategories.firstIndex(of: oldName) {
                incomeCategories[index] = trimmedNewName
                incomeCategories.sort()
                categoryUpdated = true
            }
        } else { // .expense
            if trimmedNewName.lowercased() == savingCategory.lowercased() && oldName.lowercased() != savingCategory.lowercased() {
                 // Пытаемся переименовать обычную категорию расходов в "Накопления" - запрещено, т.к. "Накопления" специальная
                return
            }
            if let index = expenseCategories.firstIndex(of: oldName) {
                expenseCategories[index] = trimmedNewName
                expenseCategories.sort()
                categoryUpdated = true
            }
        }

        if categoryUpdated && oldName != trimmedNewName {
            // Обновляем категорию в существующих транзакциях
            for i in transactions.indices {
                if transactions[i].category == oldName && transactions[i].type == type {
                    transactions[i].category = trimmedNewName
                }
            }
        }
        // @Published var transactions и @Published var ...Categories сами вызовут обновление UI
    }

    func deleteCategory(_ categoryName: String, type: TransactionType) {
        if type == .expense && categoryName.lowercased() == savingCategory.lowercased() { return } // Нельзя удалить "Накопления"
        
        // Перед удалением категории, можно предложить пользователю переназначить транзакции
        // или удалить транзакции с этой категорией. Пока просто удаляем категорию.
        if type == .income {
            incomeCategories.removeAll { $0 == categoryName }
        } else {
            expenseCategories.removeAll { $0 == categoryName }
        }
    }

    func isCategoryUsed(_ categoryName: String, type: TransactionType) -> Bool {
        return transactions.contains { $0.category == categoryName && $0.type == type }
    }

    func addAccount(name: String, isSavings: Bool) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !generalAccounts.contains(trimmedName), !savingsAccounts.contains(trimmedName) else { return }
        if isSavings {
            savingsAccounts.append(trimmedName)
            savingsAccounts.sort()
        } else {
            generalAccounts.append(trimmedName)
            generalAccounts.sort()
        }
    }

    func updateAccount(oldName: String, newName: String, wasSavings: Bool, isNowSavings: Bool) {
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNewName.isEmpty, (oldName != trimmedNewName || wasSavings != isNowSavings) else { return }

        // Проверка на дубликат нового имени
        if oldName != trimmedNewName {
            if generalAccounts.contains(trimmedNewName) || savingsAccounts.contains(trimmedNewName) {
                print("Ошибка: Счет с именем '\(trimmedNewName)' уже существует.")
                return
            }
        }

        // Удаляем старое имя из соответствующего списка
        if wasSavings {
            savingsAccounts.removeAll { $0 == oldName }
        } else {
            generalAccounts.removeAll { $0 == oldName }
        }

        // Добавляем новое имя в соответствующий список
        if isNowSavings {
            savingsAccounts.append(trimmedNewName)
            savingsAccounts.sort()
        } else {
            generalAccounts.append(trimmedNewName)
            generalAccounts.sort()
        }

        // Обновляем имя счета в транзакциях, если оно изменилось
        if oldName != trimmedNewName {
            for i in transactions.indices {
                if transactions[i].account == oldName {
                    transactions[i].account = trimmedNewName
                }
            }
        }
        // @Published свойства transactions, generalAccounts, savingsAccounts вызовут обновление
    }

    func deleteAccount(name: String, isSavings: Bool) {
        // Перед удалением счета, нужно обработать транзакции с этим счетом
        // (например, предложить перенести их на другой счет или удалить).
        // Пока просто удаляем счет из списка.
        if isSavings {
            savingsAccounts.removeAll { $0 == name }
        } else {
            generalAccounts.removeAll { $0 == name }
        }
    }

    func isAccountUsed(_ accountName: String) -> Bool {
        return transactions.contains { $0.account == accountName }
    }
    
    // Конструктор init() неявно присутствует, если нет других инициализаторов.
    // Если ты хочешь загружать данные при инициализации, тебе нужно будет добавить метод loadAllData()
    // и вызывать его в init(). Пока данные захардкожены.

    // MARK: - Static Preview Instance
    /// Статический экземпляр для использования в SwiftUI Previews.
    static var preview: FinancialDataStore = {
        let dataStore = FinancialDataStore() // Создает экземпляр с захардкоженными транзакциями
        
        // Можно добавить здесь какую-то специфичную логику для превью, если нужно.
        // Например, выбрать определенный selectedAnalyticsPeriod:
        // dataStore.selectedAnalyticsPeriod = .week
        
        // Убедимся, что есть хотя бы одна транзакция для корректного отображения виджета
        if dataStore.transactions.isEmpty {
            dataStore.addTransaction(Transaction(date: Date(), description: "Пример для превью", amount: 100, type: .income, category: "Зарплата", account: "Карта Сбер"))
        }
        print("FinancialDataStore.preview: Transactions count: \(dataStore.transactions.count)")
        return dataStore
    }()
}

// Убедись, что Transaction, TimePeriodSelection и MonthlyDataPoint определены.
// Пример Transaction (адаптируй под свою структуру):
/*
struct Transaction: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var description: String
    var amount: Double // Положительное для дохода, отрицательное для расхода
    var type: TransactionType
    var category: String
    var account: String
}

enum TransactionType: String, Codable, Hashable {
    case income = "Доход"
    case expense = "Расход"
}

struct MonthlyDataPoint: Identifiable {
    var id = UUID() // Или используй date/month + type для id, если они уникальны
    var month: String // Название месяца или дня для оси X
    var date: Date    // Дата, соответствующая этой точке (для сортировки и группировки)
    var value: Double // Сумма (доход, расход или накопления)
    var type: String  // "Доход", "Расход", "Накопления" - для группировки в графике
}
*/
