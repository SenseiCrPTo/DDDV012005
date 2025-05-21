// MyDashboardModular/Modules/Tasks/DataStore/TaskDataStore.swift
import SwiftUI
import Combine

// НЕОБХОДИМЫЕ РАСШИРЕНИЯ (должны быть на верхнем уровне файла, ВНЕ класса TaskDataStore)

extension Calendar {
    /// Возвращает DateInterval для недели, содержащей указанную дату.
    func dateIntervalOfWeek(for date: Date) -> DateInterval? {
        self.dateInterval(of: .weekOfYear, for: date)
    }

    /// Возвращает DateInterval для месяца, содержащего указанную дату.
    func dateIntervalOfMonth(for date: Date) -> DateInterval? {
        self.dateInterval(of: .month, for: date)
    }
}

extension Array where Element == Task {
    /// Сортирует задачи: невыполненные перед выполненными, затем по важности,
    /// затем по дате (ранние сначала), затем по приоритету (высший сначала), затем по названию.
    func sortedByPriorityAndDate() -> [Task] {
        self.sorted { (task1, task2) -> Bool in
            // 1. Невыполненные выше выполненных
            if !task1.isCompleted && task2.isCompleted { return true }
            if task1.isCompleted && !task2.isCompleted { return false }

            // Если обе не выполнены или обе выполнены, продолжаем сравнение:
            // 2. Важные выше неважных
            if task1.isImportant && !task2.isImportant { return true }
            if !task1.isImportant && task2.isImportant { return false }

            // 3. По дате выполнения (для невыполненных - более ранние даты выше)
            if let dueDate1 = task1.dueDate, let dueDate2 = task2.dueDate {
                if !Calendar.current.isDate(dueDate1, inSameDayAs: dueDate2) {
                    return dueDate1 < dueDate2 // Ранние даты сначала
                }
            } else if task1.dueDate != nil && task2.dueDate == nil { // Задачи с датой выше задач без даты
                return true
            } else if task1.dueDate == nil && task2.dueDate != nil {
                return false
            }
            // Если обе без даты или даты одинаковые, переходим к приоритету

            // 4. По приоритету (больший приоритет выше)
            if task1.priority != task2.priority {
                return task1.priority > task2.priority
            }

            // 5. По названию (алфавитный порядок)
            return task1.title.localizedCaseInsensitiveCompare(task2.title) == .orderedAscending
        }
    }
}


class TaskDataStore: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var projects: [TaskProject] = [] // Будет инициализирован

    init() {
        print("TaskDataStore: init started")
        // TODO: Реализовать загрузку из UserDefaults или другого хранилища
        // loadProjects()
        // loadTasks()

        // Убедимся, что проект "Входящие" всегда существует
        // Делаем это после потенциальной загрузки, чтобы не дублировать
        if projects.firstIndex(where: { $0.id == TaskProject.inbox.id }) == nil {
            projects.insert(TaskProject.inbox, at: 0)
        }
        
        if tasks.isEmpty /* && !dataWasLoadedSuccessfully (если бы была логика загрузки) */ {
            print("TaskDataStore: No tasks found or loaded. Setting up default tasks.")
            setupDefaultTasks()
        }
        print("TaskDataStore: init finished. Tasks: \(tasks.count), Projects: \(projects.count)")
    }

    private func setupDefaultTasks() {
        let inboxID = TaskProject.inbox.id
        let calendar = Calendar.current
        
        // ПОРЯДОК АРГУМЕНТОВ в Task.init (из вашего Task.swift):
        // id, title, description, isCompleted, dueDate, completionDate, projectID, priority, goalHorizon, colorHex, isImportant
        tasks = [
            Task(title: "Ответить на важное письмо (Сегодня)",
                 isCompleted: false,
                 dueDate: calendar.startOfDay(for: Date()),
                 projectID: inboxID,
                 priority: 1,
                 isImportant: true),
            Task(title: "Закончить отчет (Сегодня)",
                 isCompleted: false,
                 dueDate: calendar.startOfDay(for: Date()),
                 projectID: inboxID,
                 priority: 2),
            Task(title: "Позвонить клиенту (Вчера - просрочено)",
                 isCompleted: false,
                 dueDate: calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!,
                 projectID: inboxID,
                 priority: 3),
            Task(title: "Подготовить презентацию (Завтра)",
                 isCompleted: false,
                 dueDate: calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!,
                 projectID: inboxID),
            Task(title: "Прочитать 1 главу книги (входящие)",
                 projectID: inboxID,
                 priority: 0,
                 colorHex: "#5EAAA8"),
            Task(title: "Запланировать отпуск (Цель на год)",
                 projectID: inboxID,
                 priority: 1,
                 goalHorizon: GoalHorizon.year), // ЯВНО УКАЗЫВАЕМ GoalHorizon
            Task(title: "Сходить в спортзал (Сегодня)",
                 isCompleted: false,
                 dueDate: Date(),
                 projectID: inboxID,
                 priority: 1),
            Task(title: "Купить продукты на неделю (Неделя)",
                 isCompleted: false,
                 dueDate: calendar.date(byAdding: .day, value: 2, to: Date())!,
                 projectID: inboxID),
            Task(title: "Ежемесячный обзор бюджета (Цель)",
                 isCompleted: false,
                 dueDate: calendar.date(byAdding: .day, value: 5, to: calendar.dateIntervalOfMonth(for: Date())!.start)!, // Пример даты в текущем месяце
                 projectID: inboxID,
                 priority: 2,
                 goalHorizon: GoalHorizon.month), // ЯВНО
            Task(title: "Обновить портфолио (Цель)",
                 isCompleted: true, // isCompleted ПЕРЕД dueDate
                 dueDate: calendar.date(byAdding: .day, value: 15, to: calendar.dateIntervalOfMonth(for: Date())!.start)!, // Пример даты в текущем месяце
                 completionDate: Date(), // completionDate после dueDate
                 projectID: inboxID,
                 priority: 1,
                 goalHorizon: GoalHorizon.month) // ЯВНО
        ]
    }

    // --- CRUD для задач ---
    func addTask(title: String, description: String? = nil, isCompleted: Bool = false, dueDate: Date? = nil, completionDate: Date? = nil, projectID: UUID? = TaskProject.inbox.id, priority: Int = 0, goalHorizon: GoalHorizon? = nil, colorHex: String? = nil, isImportant: Bool = false) {
        let newTask = Task(title: title, description: description, isCompleted: isCompleted, dueDate: dueDate, completionDate: completionDate, projectID: projectID ?? TaskProject.inbox.id, priority: priority, goalHorizon: goalHorizon, colorHex: colorHex, isImportant: isImportant)
        tasks.append(newTask)
        // TODO: Сохранить задачи
    }

    func updateTask(_ task: Task) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i] = task
            // TODO: Сохранить задачи
        }
    }

    func toggleTaskCompletion(task: Task) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i].isCompleted.toggle()
            tasks[i].completionDate = tasks[i].isCompleted ? Date() : nil
            // TODO: Сохранить задачи
        }
    }

    func deleteTask(taskId: UUID) {
        tasks.removeAll { $0.id == taskId }
        // TODO: Сохранить задачи
    }

    // --- CRUD для проектов ---
    func addProject(name: String, colorHex: String? = nil) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty || projects.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) { return }
        projects.append(TaskProject(name: trimmedName, colorHex: colorHex))
        // TODO: Сохранить проекты
    }
    
    // --- Получение задач с фильтрацией ---
    func getTasks(for filter: TaskFilterOption, on selectedDate: Date, forActiveView: Bool) -> [Task] {
        let calendar = Calendar.current
        let sourceTasks = forActiveView ? self.tasks.filter { !$0.isCompleted } : self.tasks
        var filteredTasks: [Task]

        switch filter {
        case .byCalendar:
            filteredTasks = sourceTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: selectedDate)
            }
        case .today:
            filteredTasks = sourceTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDateInToday(dueDate)
            }
        case .thisWeek:
            guard let weekInterval = calendar.dateIntervalOfWeek(for: Date()) else { return [] } // Используем текущую дату для интервала недели
            filteredTasks = sourceTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return weekInterval.contains(dueDate)
            }
        case .thisMonth:
            guard let monthInterval = calendar.dateIntervalOfMonth(for: Date()) else { return [] } // Используем текущую дату для интервала месяца
            filteredTasks = sourceTasks.filter { task in
                if let dueDate = task.dueDate, monthInterval.contains(dueDate) { return true }
                if task.goalHorizon == GoalHorizon.month { return true } // ЯВНО
                return false
            }
        case .next3Months:
            let startOfToday = calendar.startOfDay(for: Date())
            guard let endOfThreeMonthsExclusive = calendar.date(byAdding: .month, value: 3, to: startOfToday) else { return [] }
            filteredTasks = sourceTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                let startOfDueDate = calendar.startOfDay(for: dueDate)
                return startOfDueDate >= startOfToday && startOfDueDate < endOfThreeMonthsExclusive
            }
        case .goalsYear: filteredTasks = sourceTasks.filter { $0.goalHorizon == GoalHorizon.year }
        case .goals3Year: filteredTasks = sourceTasks.filter { $0.goalHorizon == GoalHorizon.threeYear }
        case .goals5Year: filteredTasks = sourceTasks.filter { $0.goalHorizon == GoalHorizon.fiveYear }
        case .goals10Year: filteredTasks = sourceTasks.filter { $0.goalHorizon == GoalHorizon.tenYear }
        case .allActive: // Задачи без даты/горизонта ИЛИ из проекта "Входящие"
            filteredTasks = sourceTasks.filter { task in
                (task.dueDate == nil && task.goalHorizon == nil) || task.projectID == TaskProject.inbox.id
            }
        }
        return filteredTasks.sortedByPriorityAndDate()
    }
    
    func getTotalTasksForFilter(_ filter: TaskFilterOption, on selectedDate: Date = Date()) -> Int {
        return getTasks(for: filter, on: selectedDate, forActiveView: false).count
    }

    func getCompletedTasksForFilter(_ filter: TaskFilterOption, on selectedDate: Date = Date()) -> Int {
        let allTasksForFilter = getTasks(for: filter, on: selectedDate, forActiveView: false)
        return allTasksForFilter.filter { $0.isCompleted }.count
    }
    
    // ---- СВОЙСТВА ДЛЯ TasksWidgetView ----
    var monthlyTaskStatsForWidget: (completed: Int, total: Int) {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateIntervalOfMonth(for: Date()) else {
            return (0, 0)
        }
        let monthlyTasks = tasks.filter { task in
            (task.goalHorizon == GoalHorizon.month) || // ЯВНО
            (task.dueDate != nil && monthInterval.contains(task.dueDate!))
        }
        let completed = monthlyTasks.filter { $0.isCompleted }.count
        return (completed, monthlyTasks.count)
    }

    var topMonthlyGoalsForWidget: [Task] {
        tasks.filter { $0.goalHorizon == GoalHorizon.month && !$0.isCompleted } // ЯВНО
             .sortedByPriorityAndDate()
             .prefix(3)
             .map { $0 }
    }
    // ---- КОНЕЦ СВОЙСТВ ДЛЯ TasksWidgetView ----

    var tasksDueTodayForWidget: [Task] {
        getTasks(for: .today, on: Date(), forActiveView: true)
    }
    
    static var preview: TaskDataStore = {
        let dataStore = TaskDataStore()
        if dataStore.tasks.isEmpty {
             dataStore.addTask(title: "Базовая задача для Preview", dueDate: Date())
        }
        print("TaskDataStore.preview (standard): tasks count: \(dataStore.tasks.count)")
        return dataStore
    }()

    static func previewWithWidgetData() -> TaskDataStore {
        let dataStore = TaskDataStore()
        let todayTasksCount = dataStore.tasks.filter {Calendar.current.isDateInToday($0.dueDate ?? Date.distantPast) && !$0.isCompleted}.count
        if todayTasksCount < 2 {
            dataStore.addTask(title: "Еще задача на сегодня (Widget Preview)", dueDate: Date(), priority: 1, isImportant: false)
        }
        if dataStore.tasks.filter({$0.goalHorizon == GoalHorizon.month && !$0.isCompleted}).isEmpty { // ЯВНО
            dataStore.addTask(title: "Главная цель месяца (Widget Preview)", priority: 3, goalHorizon: GoalHorizon.month, isImportant: true) // ЯВНО
        }
        print("TaskDataStore.previewWithWidgetData: tasks count: \(dataStore.tasks.count)")
        return dataStore
    }
}
