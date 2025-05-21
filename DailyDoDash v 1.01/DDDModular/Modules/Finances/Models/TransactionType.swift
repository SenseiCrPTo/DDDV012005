import Foundation // SwiftUI здесь не нужен

enum TransactionType: String, CaseIterable, Identifiable, Hashable, Codable {
    case income = "Доход"
    case expense = "Расход"
    var id: String { self.rawValue }
}
