import Foundation
import SwiftUI // Добавим для Color, если понадобится для отладки, хотя сейчас не используется

struct HabitLog: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let habitID: UUID
    var date: Date
    var isCompleted: Bool
    var notes: String?
    var completedTimestamp: Date?
    var loggedDuration: TimeInterval?
    // Если у тебя есть поле countAchieved, добавь его сюда
    // var countAchieved: Int?

    init(id: UUID = UUID(),
         habitID: UUID,
         date: Date,
         isCompleted: Bool = true,
         notes: String? = nil,
         completedTimestamp: Date? = Date(),
         loggedDuration: TimeInterval? = nil /*, countAchieved: Int? = nil */ ) { // Если добавил countAchieved
        self.id = id
        self.habitID = habitID
        self.date = Calendar.current.startOfDay(for: date) // Нормализация даты
        self.isCompleted = isCompleted
        self.notes = notes
        self.completedTimestamp = completedTimestamp
        self.loggedDuration = loggedDuration
        // self.countAchieved = countAchieved // Если добавил countAchieved
    }

    static func == (lhs: HabitLog, rhs: HabitLog) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
