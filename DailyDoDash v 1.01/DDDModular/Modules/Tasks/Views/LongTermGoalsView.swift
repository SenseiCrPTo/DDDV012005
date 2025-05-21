// MyDashboardModular/Modules/Tasks/Views/LongTermGoalsView.swift
import SwiftUI

struct LongTermGoalsView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore
    
    @Binding var statusFilter: GoalStatusFilter
    @Binding var selectedHorizon: GoalHorizon?
    @Binding var showingAddTaskSheet: Bool

    @State private var disclosedHorizons: Set<GoalHorizon> = Set(GoalHorizon.allCases)

    private var filteredAndGroupedGoals: [GoalHorizon: [Task]] {
        // ... (логика этой функции без изменений из предпоследнего ответа)
        // 1. Отбираем только задачи, являющиеся долгосрочными целями
        let allLongTermGoals = taskDataStore.tasks.filter { $0.goalHorizon != nil }
        // 2. Фильтруем по статусу выполнения
        let statusFilteredGoals: [Task]
        switch statusFilter {
        case .all: statusFilteredGoals = allLongTermGoals
        case .active: statusFilteredGoals = allLongTermGoals.filter { !$0.isCompleted }
        case .completed: statusFilteredGoals = allLongTermGoals.filter { $0.isCompleted }
        }
        // 3. Фильтруем по выбранному горизонту
        let horizonFilteredGoals: [Task]
        if let specificHorizon = selectedHorizon {
            horizonFilteredGoals = statusFilteredGoals.filter { $0.goalHorizon == specificHorizon }
        } else {
            horizonFilteredGoals = statusFilteredGoals
        }
        // 4. Группируем и сортируем
        return Dictionary(grouping: horizonFilteredGoals, by: { $0.goalHorizon! })
            .mapValues { $0.sortedByPriorityAndDate() }
    }

    private var sortedActiveHorizons: [GoalHorizon] {
        // ... (логика без изменений)
        filteredAndGroupedGoals.filter { !$0.value.isEmpty }.keys
                             .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    private func taskBinding(for taskID: UUID) -> Binding<Task> {
        // ... (логика без изменений)
        guard let index = taskDataStore.tasks.firstIndex(where: { $0.id == taskID }) else {
            fatalError("Задача с ID \(taskID) не найдена в taskDataStore для биндинга в LongTermGoalsView.")
        }
        return $taskDataStore.tasks[index]
    }

    var body: some View {
        // ... (код List с DisclosureGroup и ForEach остается без изменений) ...
        List {
            if sortedActiveHorizons.isEmpty {
                Text("Нет долгосрочных целей по текущим фильтрам.")
                    .foregroundColor(.gray)
                    .padding()
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(sortedActiveHorizons, id: \.self) { horizon in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { disclosedHorizons.contains(horizon) },
                            set: { isExpanded in
                                if isExpanded { disclosedHorizons.insert(horizon) }
                                else { disclosedHorizons.remove(horizon) }
                            }
                        ),
                        content: {
                            if let tasksForHorizon = filteredAndGroupedGoals[horizon], !tasksForHorizon.isEmpty {
                                ForEach(tasksForHorizon) { task in
                                    let taskBinding = self.taskBinding(for: task.id)
                                    NavigationLink(destination: TaskDetailView(task: taskBinding)) {
                                        TaskRowView(task: taskBinding)
                                    }
                                }
                                .onDelete { offsets in
                                    deleteGoals(at: offsets, for: horizon)
                                }
                            }
                        },
                        label: { Text(horizon.rawValue).font(.headline) }
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Цели")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { goalsToolbarContent }
        .onAppear {
            if selectedHorizon != nil {
                disclosedHorizons = [selectedHorizon!]
            } else if !sortedActiveHorizons.isEmpty {
                disclosedHorizons = Set(sortedActiveHorizons)
            }
             print("LongTermGoalsView appeared. Status: \(statusFilter), Horizon: \(String(describing: selectedHorizon))")
        }
        .onChange(of: selectedHorizon) { _ in updateDisclosedHorizons() }
        .onChange(of: statusFilter) { _ in updateDisclosedHorizons() }
    }
    
    private func updateDisclosedHorizons() {
        // ... (логика без изменений) ...
        if selectedHorizon != nil {
            disclosedHorizons = [selectedHorizon!]
        } else if !sortedActiveHorizons.isEmpty {
            disclosedHorizons = Set(sortedActiveHorizons)
        } else {
            disclosedHorizons = []
        }
    }

    @ToolbarContentBuilder
    private var goalsToolbarContent: some ToolbarContent {
        // ... (код тулбара без изменений) ...
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Menu {
                Picker("Статус", selection: $statusFilter) {
                    ForEach(GoalStatusFilter.allCases) { status in Text(status.rawValue).tag(status) }
                }
                Picker("Горизонт", selection: $selectedHorizon) {
                    Text("Все горизонты").tag(nil as GoalHorizon?)
                    ForEach(GoalHorizon.allCases.sorted(by: { $0.sortOrder < $1.sortOrder })) { horizon in
                        Text(horizon.rawValue).tag(horizon as GoalHorizon?)
                    }
                }
            } label: { Label("Фильтр Целей", systemImage: "filter").imageScale(.large) }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
             Button { showingAddTaskSheet = true } label: { Image(systemName: "plus.circle.fill").imageScale(.large) }
        }
    }

    private func deleteGoals(at offsets: IndexSet, for horizon: GoalHorizon) {
        // ... (код без изменений) ...
        guard let tasksForHorizon = filteredAndGroupedGoals[horizon] else { return }
        offsets.map { tasksForHorizon[$0].id }.forEach { idToDelete in
            taskDataStore.deleteTask(taskId: idToDelete)
        }
    }
}

// Preview для LongTermGoalsView
struct LongTermGoalsView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @StateObject var taskDataStore: TaskDataStore
        @State var statusFilter: GoalStatusFilter
        @State var selectedHorizon: GoalHorizon?
        @State var showingAddTaskSheet: Bool = false

        init(tasks: [Task]? = nil, status: GoalStatusFilter = .all, horizon: GoalHorizon? = nil) {
            let store = TaskDataStore()
            if let predefinedTasks = tasks {
                store.tasks = predefinedTasks
            } else {
                if store.tasks.filter({ $0.goalHorizon == .year }).isEmpty {
                     store.tasks.append(Task(title: "Годовая цель (Превью)", isCompleted: false, projectID: TaskProject.inbox.id, priority: 1, goalHorizon: .year))
                }
                if store.tasks.filter({ $0.goalHorizon == .threeYear }).isEmpty {
                     store.tasks.append(Task(title: "Цель на 3 года (Превью)", isCompleted: false, projectID: TaskProject.inbox.id, priority: 1, goalHorizon: .threeYear))
                }
                if store.tasks.filter({ $0.goalHorizon == .month && $0.isCompleted }).isEmpty {
                    store.tasks.append(Task(title: "Цель на месяц (Превью, выполнена)",
                                           isCompleted: true,
                                           dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                                           completionDate: Date(),
                                           projectID: TaskProject.inbox.id,
                                           priority: 0,
                                           goalHorizon: .month))
                }
                // ИСПРАВЛЕН ПОРЯДОК АРГУМЕНТОВ ЗДЕСЬ:
                if store.tasks.filter({ $0.goalHorizon == .fiveYear && $0.isCompleted }).isEmpty { // Добавим условие, чтобы не дублировать
                    store.tasks.append(Task(title: "Еще одна на 5 лет (Превью, выполнена)",
                                           isCompleted: true, // ПЕРЕД dueDate и goalHorizon
                                           dueDate: nil,      // Пример: долгосрочная цель может не иметь точной dueDate
                                           completionDate: Date(),
                                           projectID: TaskProject.inbox.id,
                                           priority: 0,
                                           goalHorizon: .fiveYear)) // goalHorizon после priority
                }

            }
             if store.projects.firstIndex(where: { $0.id == TaskProject.inbox.id }) == nil {
                 store.projects.insert(TaskProject.inbox, at: 0)
            }
            _taskDataStore = StateObject(wrappedValue: store)
            _statusFilter = State(initialValue: status)
            _selectedHorizon = State(initialValue: horizon)
        }

        var body: some View {
            NavigationView {
                LongTermGoalsView(
                    statusFilter: $statusFilter,
                    selectedHorizon: $selectedHorizon,
                    showingAddTaskSheet: $showingAddTaskSheet
                )
                .environmentObject(taskDataStore)
                .navigationTitle("Цели (Превью)")
            }
        }
    }

    static var previews: some View {
        Group {
            PreviewWrapper(status: .all, horizon: nil)
                .previewDisplayName("Все, Все горизонты")
            
            PreviewWrapper(status: .active, horizon: .year)
                .previewDisplayName("Активные, Год")
            
            PreviewWrapper(tasks: [
                Task(title: "Моя цель на 5 лет", isCompleted: false, goalHorizon: .fiveYear), // isCompleted перед goalHorizon
                Task(title: "Еще одна на 5 лет", isCompleted: true, completionDate: Date(), goalHorizon: .fiveYear) // isCompleted перед goalHorizon
            ], status: .all, horizon: .fiveYear)
                .previewDisplayName("Все, 5 Лет (с данными)")
        }
    }
}
