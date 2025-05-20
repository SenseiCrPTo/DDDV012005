import Foundation

class MoneyViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var entries: [MoneyEntry] = []

    init() {
        load()
    }

    func load() {
        balance = MoneyRepository.shared.getCurrentBalance()
        entries = MoneyRepository.shared.getAllEntries()
    }

    func addMoney(amount: Double, note: String? = nil) {
        let entry = MoneyEntry(id: UUID(), date: Date(), amount: amount, note: note)
        MoneyRepository.shared.addEntry(entry)
        load()
    }
}
