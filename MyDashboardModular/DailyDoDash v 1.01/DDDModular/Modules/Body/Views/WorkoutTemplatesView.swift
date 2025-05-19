import SwiftUI

struct WorkoutTemplatesView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore
    
    @State private var showingAddEditSheet = false
    @State private var templateToEdit: WorkoutTemplate? = nil
    
    @State private var templateToDeleteAlert: WorkoutTemplate? = nil
    @State private var showDeleteConfirmationAlert = false

    // Вычисляемое свойство для отсортированных шаблонов
    private var sortedWorkoutTemplates: [WorkoutTemplate] {
        bodyDataStore.workoutTemplates.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        List {
            if sortedWorkoutTemplates.isEmpty {
                Text("Шаблоны тренировок еще не созданы. Нажмите \"+\", чтобы добавить.")
                    .foregroundColor(.gray)
                    .padding()
                    .listRowSeparator(.hidden) // Скрываем разделитель для этого текста
            } else {
                ForEach(sortedWorkoutTemplates) { template in
                    VStack(alignment: .leading, spacing: 5) { // Добавил spacing
                        Text(template.name)
                            .font(.headline)
                        
                        if let typeId = template.workoutTypeID,
                           let typeName = bodyDataStore.workoutTypes.first(where: {$0.id == typeId})?.name {
                            Label(typeName, systemImage: bodyDataStore.workoutTypes.first(where: {$0.id == typeId})?.iconName ?? "figure.mixed.cardio")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if template.workoutTypeID != nil { // Если ID есть, но тип не найден
                            Label("Тип: (не найден)", systemImage: "questionmark.circle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Упражнений: \(template.templateExercises.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // Более детальное отображение упражнений, если они есть
                        if !template.templateExercises.isEmpty {
                            Text("Упражнения:")
                                .font(.caption).bold().padding(.top, 2)
                            ForEach(template.templateExercises.prefix(3)) { exerciseDetail in // Убедись, что ExerciseTemplateDetail : Identifiable
                                if let ex = bodyDataStore.exercises.first(where: { $0.id == exerciseDetail.exerciseID }) {
                                    Text("- \(ex.name) (\(exerciseDetail.sets.count) подх.)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            if template.templateExercises.count > 3 {
                                Text("...и еще \(template.templateExercises.count - 3)")
                                    .font(.caption2).italic()
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4) // Небольшой вертикальный отступ для каждой строки
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.templateToEdit = template
                        self.showingAddEditSheet = true
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            self.templateToDeleteAlert = template
                            self.showDeleteConfirmationAlert = true
                        } label: {
                            Label("Удалить", systemImage: "trash.fill")
                        }
                        
                        Button {
                           self.templateToEdit = template
                           self.showingAddEditSheet = true
                        } label: {
                           Label("Редактировать", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .navigationTitle("Шаблоны тренировок")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.templateToEdit = nil
                    self.showingAddEditSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Добавить новый шаблон тренировки")
            }
        }
        .sheet(isPresented: $showingAddEditSheet, onDismiss: { templateToEdit = nil }) {
            // AddEditWorkoutTemplateView должен использовать @EnvironmentObject
            // и не принимать bodyDataStore через init
            AddEditWorkoutTemplateView(templateToEdit: self.templateToEdit)
        }
        .alert("Удалить шаблон?",
               isPresented: $showDeleteConfirmationAlert,
               presenting: templateToDeleteAlert) { templateForAlert in
            Button("Удалить", role: .destructive) {
                if let tmplToDelete = self.templateToDeleteAlert {
                    bodyDataStore.deleteWorkoutTemplate(id: tmplToDelete.id)
                }
                self.templateToDeleteAlert = nil
            }
            Button("Отмена", role: .cancel) { self.templateToDeleteAlert = nil }
        } message: { templateForAlert in
            Text("Вы уверены, что хотите удалить шаблон '\(templateForAlert.name)'? Это действие необратимо.")
        }
    }
}

struct WorkoutTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutTemplatesView()
                .environmentObject(BodyDataStore.preview) // Убедись, что BodyDataStore.preview корректно настроен
        }
    }
}
