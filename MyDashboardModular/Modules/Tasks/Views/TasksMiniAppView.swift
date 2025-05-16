// MyDashboardModular/Modules/Tasks/Views/TasksMiniAppView.swift
import SwiftUI

struct TasksMiniAppView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore
    
    @State private var showingAddTaskSheet = false
    
    @State private var calendarSelectedDateForList: Date = Date()
    @State private var activeFilterForList: TaskFilterOption = .today
    @State private var isCalendarVisibleForList: Bool = false

    @State private var goalStatusFilter: GoalStatusFilter = .all
    @State private var selectedGoalHorizonForFilter: GoalHorizon? = nil

    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Каждая вкладка теперь имеет свой NavigationView
            taskListTabWrappedInNavView // Используем новое вычисляемое свойство
            goalsListTabWrappedInNavView  // Используем новое вычисляемое свойство
            completedListTabWrappedInNavView // Используем новое вычисляемое свойство
        }
        // .navigationTitle() и .toolbar() здесь НЕ НУЖНЫ, так как каждая вкладка управляет этим сама
        .sheet(isPresented: $showingAddTaskSheet) {
            AddTaskSheet()
                .environmentObject(taskDataStore)
        }
        .onChange(of: selectedTab) { newTab in
            if newTab != 0 && isCalendarVisibleForList {
                 isCalendarVisibleForList = false
            }
        }
    }

    // Оборачиваем каждую вкладку в NavigationView
    @ViewBuilder
    private var taskListTabWrappedInNavView: some View {
        NavigationView { // <--- NavigationView для вкладки "Задачи"
            TaskListMainView(
                calendarSelectedDate: $calendarSelectedDateForList,
                activeFilter: $activeFilterForList,
                isCalendarVisible: $isCalendarVisibleForList,
                showingAddTaskSheet: $showingAddTaskSheet
            )
        }
        .navigationViewStyle(.stack) // Рекомендуется для вложенных NavigationView
        .tabItem { Label("Задачи", systemImage: "list.bullet") }.tag(0)
    }

    @ViewBuilder
    private var goalsListTabWrappedInNavView: some View {
        NavigationView { // <--- NavigationView для вкладки "Цели"
            LongTermGoalsView(
                statusFilter: $goalStatusFilter,
                selectedHorizon: $selectedGoalHorizonForFilter,
                showingAddTaskSheet: $showingAddTaskSheet
            )
        }
        .navigationViewStyle(.stack)
        .tabItem { Label("Цели", systemImage: "target") }.tag(1)
    }
    
    @ViewBuilder
    private var completedListTabWrappedInNavView: some View {
        NavigationView { // <--- NavigationView для вкладки "Выполненные"
            CompletedTasksListView(
                calendarSelectedDate: $calendarSelectedDateForList,
                activeFilter: $activeFilterForList,
                isCalendarVisible: $isCalendarVisibleForList
                // showingAddTaskSheet здесь, вероятно, не нужен
            )
        }
        .navigationViewStyle(.stack)
        .tabItem { Label("Выполненные", systemImage: "checkmark.circle.fill") }.tag(2)
    }
}

struct TasksMiniAppView_Previews: PreviewProvider {
    static var previews: some View {
        // Для превью TasksMiniAppView теперь не нужен внешний NavigationView,
        // так как каждая вкладка его имеет.
        TasksMiniAppView()
            .environmentObject(TaskDataStore.preview)
    }
}
