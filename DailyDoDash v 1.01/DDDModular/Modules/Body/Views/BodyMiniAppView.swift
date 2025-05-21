import SwiftUI

struct BodyMiniAppView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // <--- ИЗМЕНЕНО
    
    @State private var showLogWeightSheet = false
    @State private var isLoggingWorkout = false
    @State private var currentWorkoutLogForNavigation: WorkoutLog? = nil
    @State private var showingSelectTemplateSheet = false
    @State private var logToDeleteFromRecent: WorkoutLog? = nil
    @State private var showDeleteRecentLogAlert = false

    var body: some View {
        List {
            Section("Новая Тренировка") {
                Button("Начать пустую тренировку") {
                    currentWorkoutLogForNavigation = bodyDataStore.createWorkoutLogFrom(template: nil)
                    if currentWorkoutLogForNavigation != nil { isLoggingWorkout = true }
                }
                Button("Начать по шаблону") {
                    if bodyDataStore.workoutTemplates.isEmpty { print("Нет доступных шаблонов.") }
                    else { showingSelectTemplateSheet = true }
                }
            }
            Section("Вес") {
                HStack { Text("Текущий вес:"); Spacer(); Text(bodyDataStore.currentWeightString).foregroundColor(.secondary) }
                Button("Записать вес") { showLogWeightSheet = true }
            }
            Section("Статистика") {
                MetricRow(label: "Всего дней тренировок:", value: "\(bodyDataStore.totalTrainingDays)")
                MetricRow(label: "Любимый тип тренировки:", value: bodyDataStore.favoriteWorkoutTypeName)
                VStack(alignment: .leading) {
                    Text("Тренировок на этой неделе:").font(.caption).foregroundColor(.gray)
                    HabitTrackerBar(daysDone: bodyDataStore.workoutsThisWeekCount, totalDays: 7, activeColor: .indigo)
                    Text("\(bodyDataStore.workoutsThisWeekCount) из \(bodyDataStore.targetWorkoutsPerWeek > 0 ? String(bodyDataStore.targetWorkoutsPerWeek) : "~") дн. (цель)").font(.caption2).foregroundColor(.gray)
                }
            }
            Section("История тренировок") {
                if bodyDataStore.workoutLogs.isEmpty { Text("Пока нет записей о тренировках.").foregroundColor(.gray) }
                else {
                    let recentLogs = Array(bodyDataStore.workoutLogs.prefix(5))
                    ForEach(recentLogs) { logEntry in
                        Button { currentWorkoutLogForNavigation = logEntry; isLoggingWorkout = true }
                        label: { WorkoutLogRow(log: logEntry, types: bodyDataStore.workoutTypes).foregroundColor(.primary) } // WorkoutLogRow должен быть обновлен
                    }
                    .onDelete { offsets in
                        let logsToDelete = offsets.map { recentLogs[$0] }
                        if let firstLogToDelete = logsToDelete.first { self.logToDeleteFromRecent = firstLogToDelete; self.showDeleteRecentLogAlert = true }
                    }
                    if bodyDataStore.workoutLogs.count > 5 { NavigationLink("Вся история тренировок", destination: WorkoutHistoryView()) } // WorkoutHistoryView должен быть обновлен
                }
            }
            Section("Настройки и справочники") {
                // Все эти View должны быть обновлены для @EnvironmentObject
                NavigationLink("Типы тренировок", destination: WorkoutTypesListView())
                NavigationLink("Упражнения", destination: ExercisesListView())
                NavigationLink("Шаблоны тренировок", destination: WorkoutTemplatesView())
                NavigationLink(destination: WorkoutGoalSettingsView()) {
                    HStack { Text("Цель тренировок в неделю:"); Spacer(); Text("\(bodyDataStore.targetWorkoutsPerWeek) дн.").foregroundColor(.secondary) }
                }
            }
        }
        .navigationTitle("Тело")
        .sheet(isPresented: $showLogWeightSheet) { LogWeightView() } // LogWeightView должен быть обновлен
        .sheet(isPresented: $showingSelectTemplateSheet) {
            SelectWorkoutTemplateView() { selectedTemplate in // SelectWorkoutTemplateView должен быть обновлен
                currentWorkoutLogForNavigation = bodyDataStore.createWorkoutLogFrom(template: selectedTemplate)
                if currentWorkoutLogForNavigation != nil { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isLoggingWorkout = true } }
            }
        }
        .alert("Удалить тренировку?", isPresented: $showDeleteRecentLogAlert, presenting: logToDeleteFromRecent) { logEntry in
            Button("Удалить", role: .destructive) { if let logToDelete = self.logToDeleteFromRecent { bodyDataStore.deleteWorkoutLog(id: logToDelete.id) }; self.logToDeleteFromRecent = nil }
            Button("Отмена", role: .cancel) { self.logToDeleteFromRecent = nil }
        } message: { logEntry in Text("Вы уверены, что хотите удалить запись о тренировке от \(logEntry.date, style: .date)?") }
        .background(
            NavigationLink(destination: ActiveWorkoutView(workoutLogBinding: $currentWorkoutLogForNavigation), isActive: $isLoggingWorkout, label: { EmptyView() }) // ActiveWorkoutView должен быть обновлен
        )
        .onChange(of: isLoggingWorkout) { newValue in if !newValue { currentWorkoutLogForNavigation = nil } }
    }
}

struct BodyMiniAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { BodyMiniAppView().environmentObject(BodyDataStore.preview) }
    }
}
