import Foundation

class BodyRepository {
    static let shared = BodyRepository()
    private let recordsKey = "body_records"

    private init() {}

    func getRecords() -> [BodyRecord] {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let decoded = try? JSONDecoder().decode([BodyRecord].self, from: data)
        else { return [] }
        return decoded
    }

    func addRecord(_ record: BodyRecord) {
        var records = getRecords()
        records.insert(record, at: 0)
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    func deleteRecord(id: UUID) {
        var records = getRecords()
        records.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    func getLatestRecord() -> BodyRecord? {
        getRecords().first
    }
}
