import Foundation

// Представляет одну запись в дневнике.
struct DiaryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var creationTimestamp: Date
    var lastModifiedTimestamp: Date
    var title: String?
    var text: String
    var moodID: UUID?              // ID связанного MoodSetting (из MoodSetting.swift), опционально
    var isBookmarked: Bool = false

    init(id: UUID = UUID(),
         date: Date = Date(),
         creationTimestamp: Date = Date(),
         lastModifiedTimestamp: Date = Date(),
         title: String? = nil,
         text: String,
         moodID: UUID? = nil,
         isBookmarked: Bool = false) {
        self.id = id
        self.date = date
        self.creationTimestamp = creationTimestamp
        self.lastModifiedTimestamp = lastModifiedTimestamp
        // Если заголовок состоит только из пробелов, считаем его nil
        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = (trimmedTitle?.isEmpty ?? true) ? nil : trimmedTitle
        self.text = text
        self.moodID = moodID
        self.isBookmarked = isBookmarked
    }

    var displayTitle: String {
        if let t = title, !t.isEmpty { return t }
        let firstMeaningfulLine = text.split(whereSeparator: \.isNewline)
                                     .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                     .first(where: { !$0.isEmpty }) ?? ""
        return String(firstMeaningfulLine.prefix(50))
    }

    static func == (lhs: DiaryEntry, rhs: DiaryEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
