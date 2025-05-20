import Foundation

class SecondBrainViewModel: ObservableObject {
    @Published var notes: [SecondBrainNote] = []

    var currentNote: String {
        notes.first?.content ?? ""
    }

    init() {
        load()
    }

    func load() {
        notes = SecondBrainRepository.shared.getNotes()
    }

    func addNote(content: String) {
        let note = SecondBrainNote(id: UUID(), content: content, createdAt: Date())
        SecondBrainRepository.shared.addNote(note)
        load()
    }

    func deleteNote(id: UUID) {
        SecondBrainRepository.shared.deleteNote(id: id)
        load()
    }
}
