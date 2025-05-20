import Foundation

struct SecondBrainNote: Identifiable, Codable {
    let id: UUID
    var content: String
    var createdAt: Date
}
