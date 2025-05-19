// MyDashboardModular/Shared/Utils/ColorExtension.swift (или другое подходящее место)
import SwiftUI

extension Color {
    // Инициализатор из HEX-строки (убедитесь, что он у вас есть и работает)
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0 // По умолчанию полная непрозрачность

        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 { // #RRGGBB
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 { // #RRGGBBAA
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            // Можно добавить поддержку 3-х или 4-х символьных HEX, если нужно, но пока nil
            return nil
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    // Конвертер в HEX-строку (убедитесь, что он у вас есть и работает)
    func toHex() -> String? {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            // Если это, например, Color.clear или другой цвет без RGB компонентов
            return nil
        }

        let r = Int(min(max(0, components[0]), 1) * 255.0)
        let g = Int(min(max(0, components[1]), 1) * 255.0)
        let b = Int(min(max(0, components[2]), 1) * 255.0)
        // let a = components.count >= 4 ? Int(min(max(0, components[3]), 1) * 255.0) : 255 // Альфа, если нужна

        // Возвращаем HEX без альфа-канала для простоты
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    // --- МЕТОДЫ ДЛЯ СРАВНЕНИЯ ЦВЕТОВ (ВОТ ЧТО НУЖНО ДОБАВИТЬ/ПРОВЕРИТЬ) ---
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        // Для некоторых системных цветов (например, .primary, .secondary) getRed может не работать напрямую
        // Лучше сначала попытаться преобразовать в конкретное цветовое пространство, например, sRGB.
        // Однако, для большинства "простых" цветов это должно работать.
        // Если будут проблемы с .primary и т.д., нужно будет более сложное преобразование.
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    func isEqualTo(_ otherColor: Color) -> Bool {
        // Прямое сравнение Color == Color может быть ненадежным из-за разных цветовых пространств.
        // Сравнение компонентов - более надежный способ, но тоже имеет нюансы.
        // Для простоты, если они оба UIColor представимы, можно сравнить их UIColor.
        if UIColor(self) == UIColor(otherColor) {
            return true
        }
        
        // Более детальное сравнение компонентов, если прямое сравнение UIColor не подходит
        // (например, если один из них системный адаптивный цвет)
        let (r1, g1, b1, a1) = self.components()
        let (r2, g2, b2, a2) = otherColor.components()
        
        // Допуск для сравнения CGFloat
        let epsilon: CGFloat = 0.001
        
        return abs(r1 - r2) < epsilon &&
               abs(g1 - g2) < epsilon &&
               abs(b1 - b2) < epsilon &&
               abs(a1 - a2) < epsilon // Сравниваем и альфа-канал
    }
}
