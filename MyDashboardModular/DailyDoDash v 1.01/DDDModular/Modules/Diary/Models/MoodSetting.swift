import SwiftUI // Для Color

// Определяет один тип настроения (например, "Радость", "Грусть")
// с его визуальными атрибутами и числовой оценкой.
struct MoodSetting: Identifiable, Codable, Hashable, Equatable {
    let id: UUID           // Уникальный идентификатор
    var name: String         // Название настроения (например, "Счастливый", "Уставший")
    var iconName: String?    // Имя SF Symbol для иконки (опционально)
    var colorHex: String?    // Цвет в формате HEX (например, "FF0000" для красного, опционально)
    var isDefault: Bool      // Флаг, указывающий, является ли это настроение стандартным
    var ratingValue: Int     // Числовая оценка этого типа настроения от -10 до 10

    // Вычисляемое свойство для преобразования HEX в SwiftUI Color.
    // Убедись, что у тебя есть ColorExtension.swift с корректной реализацией
    // или добавь его позже.
    var color: Color? {
        guard let hex = colorHex else { return nil }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        guard hexSanitized.count == 6 else { return nil }
        var rgbValue: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgbValue) else { return nil }

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }

    init(id: UUID = UUID(),
         name: String,
         iconName: String? = nil,
         colorHex: String? = nil,
         isDefault: Bool = false,
         ratingValue: Int = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.ratingValue = ratingValue
    }

    static func == (lhs: MoodSetting, rhs: MoodSetting) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
