// MyDashboardModular/Modules/Tasks/Models/GoalHorizon.swift
import Foundation

enum GoalHorizon: String, Codable, Hashable, CaseIterable, Identifiable {
    // Убедитесь, что эти кейсы соответствуют тем, что используются в TaskDataStore
    // Порядок здесь может влиять на порядок в Picker, если не используется sortOrder
    case month = "Месяц"
    case year = "Год"
    case threeYear = "3 Года"
    case fiveYear = "5 Лет"
    case tenYear = "10 Лет"
    // Добавьте другие, если они у вас есть (например, day, week, quarter)
    
    var id: String { self.rawValue }

    // Порядок для сортировки секций в LongTermGoalsView
    // Чем меньше значение, тем выше будет секция
    var sortOrder: Int {
        switch self {
        case .month: return 0
        // case .quarter: return 1 // Если добавите
        case .year: return 2
        case .threeYear: return 3
        case .fiveYear: return 4
        case .tenYear: return 5
        // default: return 99 // Если есть другие кейсы
        }
    }
}
