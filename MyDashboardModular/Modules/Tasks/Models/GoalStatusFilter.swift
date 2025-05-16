// MyDashboardModular/Modules/Tasks/Models/GoalStatusFilter.swift
import Foundation

enum GoalStatusFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case active = "Активные"
    case completed = "Выполненные"
    // Добавьте другие статусы, если нужно
    
    var id: String { self.rawValue }
}
