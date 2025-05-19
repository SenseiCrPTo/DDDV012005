import Foundation

struct TaskProject: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var colorHex: String?

    init(id: UUID = UUID(), name: String, colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    // ЗАМЕНИ "ВАШ-УНИКАЛЬНЫЙ-UUID-ДЛЯ-INBOX" на сгенерированный тобой UUID.
    // Например: UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    // Это должен быть ОДИН И ТОТ ЖЕ UUID всегда.
    static let inbox = TaskProject(id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                                   name: "Входящие",
                                   colorHex: "8E8E93") // Пример цвета
}
