import SwiftUI // Оставим на всякий случай, хотя для enum может и не понадобиться

// MARK: - Общая Модель для Выбора Периода
enum TimePeriodSelection: String, CaseIterable, Identifiable {
    case week = "Неделя"
    case month = "Месяц"
    case year = "Год"
    case allTime = "Все время"

    var id: String { self.rawValue }

    var shortLabel: String {
        switch self {
        case .week: return "Нед."
        case .month: return "Мес."
        case .year: return "Год"
        case .allTime: return "Все"
        }
    }
}
