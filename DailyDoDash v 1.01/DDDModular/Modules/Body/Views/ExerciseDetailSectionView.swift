import SwiftUI

// Использует ExerciseLogDetail, WorkoutSet из Modules/Body/Models/
// Использует EditWorkoutSetView и WorkoutSetRow (Helper Views для "Тела")
struct ExerciseDetailSectionView: View {
    @Binding var exerciseDetail: ExerciseLogDetail
    @State private var setToEdit: WorkoutSet? = nil // Для модального редактирования подхода

    var body: some View {
        Section(header: Text(exerciseDetail.exercise.name).font(.headline)) {
            ForEach($exerciseDetail.sets) { $setEntryBinding in
                // WorkoutSetRow должен быть обновлен, если ему нужен DataStore,
                // либо он работает только с Binding<WorkoutSet>
                WorkoutSetRow(set: $setEntryBinding) {
                    self.setToEdit = $setEntryBinding.wrappedValue
                }
            }
            .onDelete(perform: deleteSet)

            Button {
                addSetToExercise()
            } label: {
                Label("Добавить подход", systemImage: "plus")
            }
        }
        .sheet(item: $setToEdit) { actualSetToEdit in
            // Находим актуальный Binding для передачи в EditWorkoutSetView
            if let index = exerciseDetail.sets.firstIndex(where: { $0.id == actualSetToEdit.id }) {
                // EditWorkoutSetView также должен быть обновлен, если ему нужен DataStore
                // и не должен принимать bodyDataStore через init, если он использует @EnvironmentObject
                EditWorkoutSetView(set: $exerciseDetail.sets[index])
            }
        }
    }

    private func deleteSet(at offsets: IndexSet) {
        exerciseDetail.sets.remove(atOffsets: offsets)
    }

    private func addSetToExercise() {
        let newSetIndex = (exerciseDetail.sets.last?.setIndex ?? 0) + 1
        // Убедись, что WorkoutSet инициализируется правильно и все необходимые ID передаются.
        // Например, если exerciseID нужен в WorkoutSet, убедись, что он есть.
        exerciseDetail.sets.append(WorkoutSet(exerciseID: exerciseDetail.exercise.id, setIndex: newSetIndex))
    }
}

// Previews для ExerciseDetailSectionView может потребовать создания моковых Binding.
// Это может быть немного сложно, поэтому для таких "внутренних" компонентов превью иногда опускают
// или создают очень специфичные обертки.
/*
struct ExerciseDetailSectionView_Previews: PreviewProvider {
    static var previews: some View {
        // Нужен моковый ExerciseLogDetail и Binding к нему
        StatefulPreviewWrapper_ExerciseDetailSection()
    }
}

struct StatefulPreviewWrapper_ExerciseDetailSection: View {
    @State var sampleExerciseDetail: ExerciseLogDetail = ExerciseLogDetail(
        exercise: Exercise(name: "Пример Упражнения"), // Убедись, что Exercise имеет такой init
        sets: [
            WorkoutSet(exerciseID: UUID(), setIndex: 1, reps: 10, weight: 50),
            WorkoutSet(exerciseID: UUID(), setIndex: 2, reps: 8, weight: 55)
        ]
    )
    var body: some View {
        Form { // Оборачиваем в Form для корректного отображения Section
            ExerciseDetailSectionView(exerciseDetail: $sampleExerciseDetail)
        }
        .environmentObject(BodyDataStore.preview) // Если дочерние View его используют
    }
}
*/
