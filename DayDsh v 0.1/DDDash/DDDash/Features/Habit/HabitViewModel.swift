import Foundation

class HabitViewModel: ObservableObject {
    @Published var habits: [HabitItem] = []

    var currentHabit: String {
        habits.first?.name ?? ""
    }

    init() {
        load()
    }

    func load() {
        habits = HabitRepository.shared.getHabits()
    }

    func addHabit(name: String) {
        let habit = HabitItem(id: UUID(), name: name, isDone: false, createdAt: Date())
        HabitRepository.shared.addHabit(habit)
        load()
    }

    func toggleDone(id: UUID) {
        HabitRepository.shared.toggleDone(id: id)
        load()
    }

    func deleteHabit(id: UUID) {
        HabitRepository.shared.deleteHabit(id: id)
        load()
    }
}
