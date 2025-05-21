import Foundation // SwiftUI здесь не нужен

struct MonthlyDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let date: Date
    let value: Double
    var type: String  // "Доход", "Расход", "Накопления"
}
