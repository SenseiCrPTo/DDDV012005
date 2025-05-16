import SwiftUI

struct WorkoutGoalSettingsView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore
    @State private var selectedGoal: Int

    private let goalRange = 1...7

    init() {
        _selectedGoal = State(initialValue: 3) // Временное значение, будет перезаписано в onAppear
    }

    var body: some View {
        Form {
            Section(header: Text("Цель тренировок в неделю")) {
                Stepper(value: $selectedGoal, in: goalRange) {
                    Text("\(selectedGoal) дн./нед.")
                }
            }
        }
        .navigationTitle("Настроить цель")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let currentGoal = bodyDataStore.targetWorkoutsPerWeek
            if goalRange.contains(currentGoal) {
                selectedGoal = currentGoal
            } else {
                selectedGoal = 3
            }
        }
        .onDisappear {
            if bodyDataStore.targetWorkoutsPerWeek != selectedGoal {
                bodyDataStore.setTargetWorkoutsExplicitly(count: selectedGoal)
            }
        }
    }
}

struct WorkoutGoalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutGoalSettingsView()
                .environmentObject(BodyDataStore.preview)
        }
    }
}
