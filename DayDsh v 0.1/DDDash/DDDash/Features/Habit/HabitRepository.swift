import Foundation

class HabitRepository {
    static let shared = HabitRepository()
    private let habitsKey = "habit_items"

    private init() {}

    func getHabits() -> [HabitItem] {
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let decoded = try? JSONDecoder().decode([HabitItem].self, from: data)
        else { return [] }
        return decoded
    }

    func saveHabits(_ habits: [HabitItem]) {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
    }

    func addHabit(_ habit: HabitItem) {
        var habits = getHabits()
        habits.insert(habit, at: 0)
        saveHabits(habits)
    }

    func toggleDone(id: UUID) {
        var habits = getHabits()
        if let index = habits.firstIndex(where: { $0.id == id }) {
            habits[index].isDone.toggle()
            saveHabits(habits)
        }
    }

    func deleteHabit(id: UUID) {
        var habits = getHabits()
        habits.removeAll { $0.id == id }
        saveHabits(habits)
    }

    func getCurrentHabit() -> String {
        getHabits().first?.name ?? ""
    }
}
