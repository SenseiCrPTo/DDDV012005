import Foundation

struct Exercise: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var description: String?

    init(id: UUID = UUID(), name: String = "", description: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
    }
}
