import SwiftUI

// Вспомогательный enum для выбора "базового" типа частоты в Picker
enum HabitFrequencyBaseType: String, CaseIterable, Identifiable, Hashable { // Добавил Hashable
    case daily = "Ежедневно"
    case specificDaysOfWeek = "Выбранные дни недели"
    case timesPerWeek = "Раз в неделю"
    case everyXDays = "Каждые X дней"
    
    var id: String { self.rawValue }
}

// Перечисление для частоты выполнения привычки
enum HabitFrequency: Codable, Hashable, Identifiable {
    case daily
    case specificDaysOfWeek(days: Set<Int>)
    case timesPerWeek(count: Int)
    case everyXDays(days: Int)

    // Identifiable conformance
    var id: String {
        switch self {
        case .daily: return "daily"
        case .specificDaysOfWeek(let days): return "specificDaysOfWeek_\(days.sorted().map(String.init).joined(separator: "_"))"
        case .timesPerWeek(let count): return "timesPerWeek_\(count)"
        case .everyXDays(let days): return "everyXDays_\(days)"
        }
    }

    var displayName: String {
        switch self {
        case .daily:
            return "Ежедневно"
        case .specificDaysOfWeek(let days):
            // Убедимся, что дни недели соответствуют Calendar.current.weekdaySymbols (1 = Воскресенье, ..., 7 = Суббота по умолчанию)
            // или Calendar.current.shortWeekdaySymbols
            // Для согласованности с daySymbols в AddEditHabitView, который может учитывать firstWeekday
            // Лучше передавать Calendar.current в статический метод для единообразия
            let calendar = Calendar.current
            var symbols = calendar.shortWeekdaySymbols // ["Sun", "Mon", ...]
            // Если daySymbols в AddEditHabitView сдвигает воскресенье в конец (для firstWeekday = 2 (Понедельник))
            // то здесь нужно это учитывать или получать символы тем же способом.
            // Пока оставим стандартные shortWeekdaySymbols, предполагая, что Set<Int> хранит стандартные номера дней (1-7)
            
            let dayNames = days.sorted().map { dayIndex -> String in
                // dayIndex должен быть 1-7. weekdaySymbols[0] это "Воскресенье"
                // Поэтому, если days хранит 1 для Воскресенья, 2 для Понедельника и т.д.
                guard dayIndex >= 1 && dayIndex <= 7 else { return "?" }
                return symbols[dayIndex - 1]
            }.joined(separator: ", ")
            
            return dayNames.isEmpty ? "Дни не выбраны" : "Дни: \(dayNames)"
        case .timesPerWeek(let count):
            return "\(count) раз(а) в неделю"
        case .everyXDays(let days):
            return "Каждые \(days) дн."
        }
    }
    
    var baseType: HabitFrequencyBaseType {
        switch self {
        case .daily: return .daily
        case .specificDaysOfWeek: return .specificDaysOfWeek
        case .timesPerWeek: return .timesPerWeek
        case .everyXDays: return .everyXDays
        }
    }

    // Стандартные значения для каждого baseType, полезно для Picker
    static func defaultForBaseType(_ baseType: HabitFrequencyBaseType, currentDays: Set<Int> = [], currentCount: Int = 1, currentXDays: Int = 1) -> HabitFrequency {
        switch baseType {
        case .daily: return .daily
        case .specificDaysOfWeek: return .specificDaysOfWeek(days: currentDays.isEmpty ? [Calendar.current.component(.weekday, from: Date())] : currentDays) // По умолчанию текущий день или переданные
        case .timesPerWeek: return .timesPerWeek(count: currentCount > 0 ? currentCount : 1)
        case .everyXDays: return .everyXDays(days: currentXDays > 0 ? currentXDays : 1)
        }
    }
}


struct Habit: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    var iconName: String
    var colorHex: String // Храним HEX
    var frequency: HabitFrequency
    
    var goalCount: Int? // ТЕКУЩИЙ прогресс для количественных целей (например, выпито стаканов воды)
    var goalTargetCount: Int // ЦЕЛЕВОЕ количество (например, 8 стаканов воды)
    var goalDuration: TimeInterval? // Целевая длительность в секундах (например, 600 секунд для 10 мин медитации)
    
    var showOnWidget: Bool
    var creationDate: Date
    var reminderTime: Date? // Время напоминания
    var reminderDays: Set<Int>? // Дни недели для напоминания (1-7, где 1=Воскресенье или согласно Calendar.current.firstWeekday)
    var isArchived: Bool

    // Вычисляемое свойство для Color из HEX
    var color: Color {
        Color(hex: colorHex) ?? .gray // Используем расширение
    }

    // Вычисляемое свойство для UIColor из HEX
    var uiColor: UIColor {
        UIColor(hex: colorHex) ?? .gray // Используем расширение для UIColor
    }

    init(id: UUID = UUID(),
         name: String,
         description: String? = nil,
         iconName: String = "star.fill",
         colorHex: String = "007AFF", // По умолчанию синий
         frequency: HabitFrequency = .daily,
         goalCount: Int? = nil,
         goalTargetCount: Int = 1, // По умолчанию цель = 1 (например, 1 раз выполнить)
         goalDuration: TimeInterval? = nil,
         showOnWidget: Bool = false,
         creationDate: Date = Date(),
         reminderTime: Date? = nil,
         reminderDays: Set<Int>? = nil,
         isArchived: Bool = false) {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.iconName = iconName
        self.colorHex = colorHex
        self.frequency = frequency
        self.goalCount = goalCount
        // Если есть количественная цель (goalCount != nil) или цель по длительности (goalDuration != nil),
        // и goalTargetCount не был явно задан как > 1, то он остается 1.
        // Если же цель была указана > 1, то используем ее.
        self.goalTargetCount = (goalCount != nil || goalDuration != nil) ? (goalTargetCount > 0 ? goalTargetCount : 1) : 1
        self.goalDuration = goalDuration
        self.showOnWidget = showOnWidget
        self.creationDate = creationDate
        self.reminderTime = reminderTime
        self.reminderDays = reminderDays
        self.isArchived = isArchived
    }

    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Расширение для UIColor для инициализации из HEX-строки
// Это расширение может быть вынесено в отдельный файл утилит, если используется в других местах.
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red, green, blue, alpha: CGFloat
        if hexSanitized.count == 6 {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
            alpha = 1.0
        } else if hexSanitized.count == 8 { // With alpha
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil // Invalid length
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
