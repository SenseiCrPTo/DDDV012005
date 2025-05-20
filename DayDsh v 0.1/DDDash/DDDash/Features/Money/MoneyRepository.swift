import Foundation

class MoneyRepository {
    static let shared = MoneyRepository()
    private let balanceKey = "money_balance"
    private let entriesKey = "money_entries"

    private init() {}

    func getCurrentBalance() -> Double {
        UserDefaults.standard.double(forKey: balanceKey)
    }

    func saveBalance(_ value: Double) {
        UserDefaults.standard.set(value, forKey: balanceKey)
    }

    func getAllEntries() -> [MoneyEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey),
              let decoded = try? JSONDecoder().decode([MoneyEntry].self, from: data)
        else { return [] }
        return decoded
    }

    func addEntry(_ entry: MoneyEntry) {
        var entries = getAllEntries()
        entries.insert(entry, at: 0)
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: entriesKey)
        }
        saveBalance(getCurrentBalance() + entry.amount)
    }
}
