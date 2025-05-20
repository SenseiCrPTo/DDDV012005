import Foundation

class DashboardViewModel: ObservableObject {
    @Published var money: Double = MoneyRepository.shared.getCurrentBalance()
    @Published var todos: [String] = TodoRepository.shared.getTodos().map { $0.title } // <--- исправлено
    @Published var bodyInfo: String = BodyRepository.shared.getBodyInfo() // <--- исправлено, функция см. ниже
    @Published var secondBrain: String = SecondBrainRepository.shared.getCurrentNote()
    @Published var habit: String = HabitRepository.shared.getCurrentHabit()
}
