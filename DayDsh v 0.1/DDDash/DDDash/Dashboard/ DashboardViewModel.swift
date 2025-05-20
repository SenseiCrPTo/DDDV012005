// DashboardViewModel.swift
import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var money: Double = 245_000
    @Published var todos: [String] = ["Finish project", "Call client"]
    @Published var bodyInfo: String = "82 kg, 10 000 steps"
    @Published var secondBrain: String = "Read article on productivity"
    @Published var habit: String = "Drink water"
}
