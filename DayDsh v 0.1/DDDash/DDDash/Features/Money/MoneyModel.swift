import Foundation

struct MoneyEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let note: String?
}
