import SwiftUI

@main
struct MyDashboardStructuredApp: App {
    @StateObject var habitDataStore = HabitDataStore()
    @StateObject var diaryDataStore = DiaryDataStore()   // Раскомментировано
    @StateObject var taskDataStore = TaskDataStore()     // Раскомментировано
    @StateObject var financeDataStore = FinancialDataStore()
    @StateObject var bodyDataStore = BodyDataStore()     // Раскомментировано

    var body: some Scene {
        WindowGroup {
            MainDashboardView()
                .environmentObject(habitDataStore)
                .environmentObject(diaryDataStore)    // Раскомментировано
                .environmentObject(taskDataStore)     // Раскомментировано
                .environmentObject(financeDataStore)
                .environmentObject(bodyDataStore)     // Раскомментировано
        }
    }
}
