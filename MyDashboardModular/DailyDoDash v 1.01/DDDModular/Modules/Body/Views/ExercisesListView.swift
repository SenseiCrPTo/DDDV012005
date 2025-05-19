import SwiftUI

struct ExercisesListView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // Уже @EnvironmentObject, отлично!
    
    @State private var showingAddEditSheet = false
    @State private var exerciseToEdit: Exercise? = nil
    @State private var exerciseToDelete: Exercise? = nil
    @State private var showDeleteConfirmationAlert = false
    @State private var showUsageAlert = false

    var body: some View {
        List {
            if bodyDataStore.exercises.isEmpty {
                Text("Упражнения еще не добавлены.")
                    .foregroundColor(.gray)
                    .padding()
            }
            ForEach(bodyDataStore.exercises.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name).font(.headline)
                    if let description = exercise.description, !description.isEmpty {
                        Text(description).font(.caption).foregroundColor(.gray).lineLimit(2)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    self.exerciseToEdit = exercise
                    self.showingAddEditSheet = true
                }
                .swipeActions(edge: .trailing) { /* Твой код swipeActions */ }
            }
        }
        .navigationTitle("Упражнения")
        .toolbar { /* Твой toolbar */ }
        .sheet(isPresented: $showingAddEditSheet, onDismiss: { exerciseToEdit = nil }) {
            // AddEditExerciseView должен использовать @EnvironmentObject
            AddEditExerciseView(bodyDataStore: bodyDataStore, exerciseToEdit: self.exerciseToEdit)
        }
        .alert("Удалить упражнение?", isPresented: $showDeleteConfirmationAlert, presenting: exerciseToDelete) { ex in /* Твой код */ } message: { ex in /* Твой код */ }
        .alert("Упражнение используется", isPresented: $showUsageAlert) { /* Твой код */ } message: { /* Твой код */ }
    }
}

struct ExercisesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExercisesListView()
                .environmentObject(BodyDataStore.preview)
        }
    }
}
