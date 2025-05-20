import Foundation

struct BodyRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    var weight: Double?   // В кг
    var steps: Int?       // За день
}
