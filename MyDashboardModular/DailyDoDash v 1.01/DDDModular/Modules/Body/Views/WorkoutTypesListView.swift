import SwiftUI

struct WorkoutTypesListView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore
    
    @State private var showingAddEditSheet = false
    @State private var typeToEdit: WorkoutType? = nil
    @State private var typeToDelete: WorkoutType? = nil
    @State private var showDeleteConfirmationAlert = false
    @State private var showUsageAlert = false

    private var sortedWorkoutTypes: [WorkoutType] {
        bodyDataStore.workoutTypes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        List { // Строка 16, на которую указывала ошибка, сама по себе не проблема
            if sortedWorkoutTypes.isEmpty {
                Text("Типы тренировок еще не добавлены.")
                    .foregroundColor(.gray)
                    .padding()
                    .listRowSeparator(.hidden)
            } else {
                ForEach(sortedWorkoutTypes) { type in
                    // Используем нашу новую WorkoutTypeRowView
                    WorkoutTypeRowView(
                        type: type,
                        onEdit: { selectedType in
                            self.typeToEdit = selectedType
                            self.showingAddEditSheet = true
                        },
                        onDeleteAttempt: { selectedType in
                            // Логика проверки использования типа перед удалением
                            let isUsedInLogs = bodyDataStore.workoutLogs.contains { $0.workoutTypeID == selectedType.id }
                            let isUsedInTemplates = bodyDataStore.workoutTemplates.contains { $0.workoutTypeID == selectedType.id }
                            
                            self.typeToDelete = selectedType // Устанавливаем typeToDelete для обоих алертов
                            if isUsedInLogs || isUsedInTemplates {
                                self.showUsageAlert = true
                            } else {
                                self.showDeleteConfirmationAlert = true
                            }
                        }
                    )
                }
            }
        }
        .navigationTitle("Типы тренировок")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                 Button {
                    self.typeToEdit = nil // Для создания нового типа
                    self.showingAddEditSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Добавить новый тип тренировки")
            }
        }
        .sheet(isPresented: $showingAddEditSheet, onDismiss: { typeToEdit = nil }) {
            // Убедитесь, что AddEditWorkoutTypeView СУЩЕСТВУЕТ и ОБНОВЛЕН для @EnvironmentObject
            // И что он принимает workoutTypeToEdit: WorkoutType?
            AddEditWorkoutTypeView(workoutTypeToEdit: self.typeToEdit)
                .environmentObject(bodyDataStore) // Передаем environmentObject если он нужен в AddEditWorkoutTypeView
        }
        .alert("Удалить тип тренировки?", isPresented: $showDeleteConfirmationAlert, presenting: typeToDelete) { typeForAlert in // typeForAlert - это развернутое значение typeToDelete
            Button("Удалить", role: .destructive) {
                if let typeToDeleteConfirmed = self.typeToDelete { // Используем сохраненное состояние
                    bodyDataStore.deleteWorkoutType(id: typeToDeleteConfirmed.id)
                }
                self.typeToDelete = nil // Сбрасываем после действия
            }
            Button("Отмена", role: .cancel) {
                self.typeToDelete = nil // Сбрасываем при отмене
            }
        } message: { typeForAlert in
            Text("Вы уверены, что хотите удалить тип '\(typeForAlert.name)'? Это действие необратимо.")
        }
        .alert("Тип используется", isPresented: $showUsageAlert, presenting: typeToDelete) { typeForAlert in
            Button("OK", role: .cancel) {
                self.typeToDelete = nil // Сбрасываем
            }
        } message: { typeForAlert in // typeForAlert будет не nil, если алерт показан
            // Убедимся, что typeForAlert.name доступно, если typeToDelete был установлен
            Text("Тип '\(typeForAlert.name)' используется в записях тренировок или шаблонах и не может быть удален.")
        }
    }
}

// Preview остается без изменений
struct WorkoutTypesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutTypesListView()
                .environmentObject(BodyDataStore.preview)
        }
    }
}
