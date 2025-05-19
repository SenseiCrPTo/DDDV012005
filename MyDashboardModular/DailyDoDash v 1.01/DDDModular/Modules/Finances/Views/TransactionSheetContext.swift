import Foundation // SwiftUI здесь не нужен

// Использует Transaction и TransactionType из Modules/Finances/Models/
struct TransactionSheetContext: Identifiable {
    let id = UUID()
    var type: TransactionType
    var category: String? // Для предустановки категории "Накопления"
    var transactionToEdit: Transaction?

    // Инициализатор для новой транзакции (Доход, Расход)
    init(type: TransactionType, category: String? = nil) {
        self.type = type
        self.category = category
        self.transactionToEdit = nil
    }

    // Инициализатор для редактирования существующей транзакции
    init(transactionToEdit: Transaction) {
        self.type = transactionToEdit.type
        self.category = transactionToEdit.category // Берем из транзакции
        self.transactionToEdit = transactionToEdit
    }
}
