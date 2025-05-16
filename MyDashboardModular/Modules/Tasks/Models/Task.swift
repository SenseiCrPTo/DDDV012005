// MyDashboardModular/Modules/Tasks/Models/Task.swift
import Foundation

// Убедись, что GoalHorizon и TaskProject.inbox определены и доступны
// (например, в Models/Tasks/GoalHorizon.swift и Models/Tasks/TaskProject.swift)

struct Task: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var description: String?
    var isCompleted: Bool
    var dueDate: Date?
    var completionDate: Date?
    var projectID: UUID?
    var priority: Int
    var goalHorizon: GoalHorizon? // Убедись, что GoalHorizon определен
    var colorHex: String?
    var isImportant: Bool

    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else {
            return false
        }
        return Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: Date())
    }

    init(id: UUID = UUID(),
         title: String,
         description: String? = nil,
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         completionDate: Date? = nil,
         projectID: UUID? = TaskProject.inbox.id, // Используем .inbox
         priority: Int = 0,
         goalHorizon: GoalHorizon? = nil, // Убедись, что GoalHorizon определен
         colorHex: String? = nil,
         isImportant: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        if isCompleted {
            self.completionDate = completionDate ?? Date()
        } else {
            self.completionDate = nil
        }
        self.projectID = projectID
        self.priority = priority
        self.goalHorizon = goalHorizon
        self.colorHex = colorHex
        self.isImportant = isImportant
    }
}
