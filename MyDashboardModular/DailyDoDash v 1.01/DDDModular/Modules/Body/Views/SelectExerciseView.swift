import SwiftUI

struct SelectExerciseView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // <--- ИЗМЕНЕНО
    var onExerciseSelected: (Exercise) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""

    // init(bodyDataStore: BodyDataStore, ... ) // <--- УДАЛЕН параметр bodyDataStore
    // Текущий init(onExerciseSelected: ...) подойдет, если он был только для этого.

    var filteredExercises: [Exercise] {
        let sortedExercises = bodyDataStore.exercises.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        if searchText.isEmpty {
            return sortedExercises
        } else {
            return sortedExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredExercises) { exercise in
                    Button(exercise.name) {
                        onExerciseSelected(exercise)
                        dismiss()
                    }
                    .foregroundColor(.primary) // Чтобы текст кнопки был стандартного цвета
                }
            }
            .searchable(text: $searchText, prompt: "Найти упражнение")
            .navigationTitle("Выбрать упражнение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Можно изменить на .navigationBarLeading
                    Button("Отмена") { // Изменил "Готово" на "Отмена", так как выбор происходит по тапу
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SelectExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        SelectExerciseView(onExerciseSelected: { exercise in
            print("Превью: Выбрано упражнение - \(exercise.name)")
        })
        .environmentObject(BodyDataStore.preview) // <--- ИЗМЕНЕНО
    }
}
