import Foundation

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isDone: Bool
    var dueDate: Date?
}
