import Foundation // Для Set

// MARK: - Утилиты для Последовательностей
extension Sequence where Element: Hashable {
    var unique: [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
