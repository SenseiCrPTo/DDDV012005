import Foundation

class SecondBrainRepository {
    static let shared = SecondBrainRepository()
    private let notesKey = "secondbrain_notes"

    private init() {}

    func getNotes() -> [SecondBrainNote] {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let decoded = try? JSONDecoder().decode([SecondBrainNote].self, from: data)
        else { return [] }
        return decoded
    }

    func addNote(_ note: SecondBrainNote) {
        var notes = getNotes()
        notes.insert(note, at: 0)
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: notesKey)
        }
    }

    func deleteNote(id: UUID) {
        var notes = getNotes()
        notes.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: notesKey)
        }
    }

    func getCurrentNote() -> String {
        getNotes().first?.content ?? ""
    }
}
