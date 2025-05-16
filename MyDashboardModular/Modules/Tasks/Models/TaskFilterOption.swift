// MyDashboardModular/Modules/Tasks/Models/TaskFilterOption.swift
import Foundation

enum TaskFilterOption: String, CaseIterable, Identifiable {
    case byCalendar = "По календарю"
    case today = "На сегодня"
    case thisWeek = "На неделю"
    case thisMonth = "На месяц"
    case next3Months = "На 3 месяца"
    case goalsYear = "Цели на год"
    case goals3Year = "Цели на 3 года"
    case goals5Year = "Цели на 5 лет"
    case goals10Year = "Цели на 10 лет"
    case allActive = "Все активные (входящие)"
    
    var id: String { self.rawValue }

    // ВАЖНО: Это свойство должно здесь быть!
    var displayName: String {
        // Для "allActive" можно вернуть что-то более общее, если он не только для "входящих"
        if self == .allActive { return "Входящие/Без даты" }
        return self.rawValue
    }
}
