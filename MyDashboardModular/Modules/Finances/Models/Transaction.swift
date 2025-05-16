import Foundation // SwiftUI здесь не нужен

struct Transaction: Identifiable, Hashable, Codable {
    let id: UUID
    var date: Date
    var description: String
    var amount: Double
    var type: TransactionType // Использует enum, определенный ранее
    var category: String
    var account: String

    init(id: UUID = UUID(), date: Date, description: String, amount: Double, type: TransactionType, category: String, account: String) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.type = type
        self.category = category
        self.account = account
    }
}
