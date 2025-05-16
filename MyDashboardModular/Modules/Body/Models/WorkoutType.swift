import Foundation

struct WorkoutType: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var iconName: String? // SF Symbol name

    init(id: UUID = UUID(), name: String = "", iconName: String? = nil) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}
