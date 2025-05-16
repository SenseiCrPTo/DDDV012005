import SwiftUI

struct WorkoutHistoryView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // <--- ИЗМЕНЕНО
    @State private var workoutToEdit: WorkoutLog? = nil

    // init(bodyDataStore: BodyDataStore) { ... } // <--- УДАЛИТЬ init

    var body: some View {
        List {
            // workoutLogs уже должны быть отсортированы в BodyDataStore
            ForEach(bodyDataStore.workoutLogs) { logEntry in
                Button {
                    workoutToEdit = logEntry
                } label: {
                    WorkoutLogRow(log: logEntry, types: bodyDataStore.workoutTypes)
                        .foregroundColor(.primary)
                }
            }
            .onDelete { indexSet in
                indexSet.map { bodyDataStore.workoutLogs[$0].id }.forEach { id in
                    bodyDataStore.deleteWorkoutLog(id: id)
                }
            }
        }
        .navigationTitle("История тренировок")
        .sheet(item: $workoutToEdit) { logToEditFromItem in // logToEditFromItem - это развернутый workoutToEdit
            NavigationView { // NavigationView для toolbar в ActiveWorkoutView
                ActiveWorkoutView(workoutLogBinding: Binding( // Создаем Binding к workoutToEdit
                    get: { self.workoutToEdit },
                    set: { self.workoutToEdit = $0 }
                ))
                // ActiveWorkoutView должен сам получить bodyDataStore из окружения
            }
        }
    }
}

struct WorkoutHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutHistoryView()
                .environmentObject(BodyDataStore.preview) // <--- ИЗМЕНЕНО
        }
    }
}
