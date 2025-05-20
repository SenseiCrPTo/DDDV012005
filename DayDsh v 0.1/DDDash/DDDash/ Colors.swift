// Colors.swift
import SwiftUI

extension Color {
    static let mainText = Color(hex: "#313131")
    static let backgroundMain = Color(hex: "#F5F5F5")
    static let widgetBackground = Color.white
    static let dashAccent = Color(hex: "#F53F33")
    static let borderRed = Color(hex: "#F53F33")
    static let borderBlue = Color(hex: "#4A90E2")
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
