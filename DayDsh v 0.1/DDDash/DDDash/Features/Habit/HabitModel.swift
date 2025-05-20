import Foundation

struct HabitItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var isDone: Bool
    var createdAt: Date
}
