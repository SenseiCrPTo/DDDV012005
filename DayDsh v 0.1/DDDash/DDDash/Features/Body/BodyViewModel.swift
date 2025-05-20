import Foundation

class BodyViewModel: ObservableObject {
    @Published var records: [BodyRecord] = []

    var latestRecord: BodyRecord? {
        records.first
    }

    init() {
        load()
    }

    func load() {
        records = BodyRepository.shared.getRecords()
    }

    func addRecord(weight: Double?, steps: Int?) {
        let record = BodyRecord(id: UUID(), date: Date(), weight: weight, steps: steps)
        BodyRepository.shared.addRecord(record)
        load()
    }

    func deleteRecord(id: UUID) {
        BodyRepository.shared.deleteRecord(id: id)
        load()
    }
}
