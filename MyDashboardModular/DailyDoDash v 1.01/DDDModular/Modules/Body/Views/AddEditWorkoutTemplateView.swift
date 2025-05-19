import SwiftUI

struct AddEditWorkoutTemplateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bodyDataStore: BodyDataStore
    
    var templateToEdit: WorkoutTemplate?
    
    @State private var templateName: String
    @State private var selectedWorkoutTypeID: UUID?
    @State private var templateExercises: [ExerciseTemplateDetail] // ExerciseTemplateDetail ДОЛЖЕН БЫТЬ Identifiable
    
    @State private var showingSelectExerciseSheet = false
    
    private var isEditing: Bool { templateToEdit != nil }
    private var navigationTitleString: String { isEditing ? "Редактировать шаблон" : "Новый шаблон" }

    init(templateToEdit: WorkoutTemplate? = nil) {
        self.templateToEdit = templateToEdit
        if let template = templateToEdit {
            _templateName = State(initialValue: template.name)
            _selectedWorkoutTypeID = State(initialValue: template.workoutTypeID)
            _templateExercises = State(initialValue: template.templateExercises)
        } else {
            _templateName = State(initialValue: "")
            _selectedWorkoutTypeID = State(initialValue: nil)
            _templateExercises = State(initialValue: [])
        }
    }

    private var generalInfoSection: some View {
        Section(header: Text("Общая информация")) {
            TextField("Название шаблона", text: $templateName)
            Picker("Тип тренировки (опционально)", selection: $selectedWorkoutTypeID) {
                Text("Не выбрано").tag(nil as UUID?)
                ForEach(bodyDataStore.workoutTypes.sorted { $0.name < $1.name }) { type in
                    Text(type.name).tag(type.id as UUID?)
                }
            }
        }
    }

    private var exercisesSection: some View {
        Section(header: Text("Упражнения в шаблоне")) {
            if templateExercises.isEmpty {
                Text("Нет упражнений. Нажмите \"+\" ниже, чтобы добавить.")
                    .foregroundColor(.gray).padding(.vertical)
            } else {
                // $exDetailBindingItem здесь это Binding<ExerciseTemplateDetail>
                ForEach($templateExercises) { $exDetailBindingItem in
                    NavigationLink(destination: EditExerciseTemplateDetailView(exerciseDetail: $exDetailBindingItem)) { // EditExerciseTemplateDetailView должен быть обновлен
                        // Прямой доступ к wrappedValue для получения свойств объекта
                        if let exercise = bodyDataStore.exercises.first(where: { $0.id == exDetailBindingItem.exerciseID }) {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Text("\(exDetailBindingItem.sets.count) подх.") // ИСПРАВЛЕННАЯ СТРОКА 57
                                    .font(.caption).foregroundColor(.gray)
                            }
                        } else {
                            Text("Неизвестное упражнение (ID: \(exDetailBindingItem.exerciseID.uuidString.prefix(8)))") // ИСПРАВЛЕННАЯ СТРОКА 61
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: deleteExerciseFromTemplate)
            }
            Button { showingSelectExerciseSheet = true } label: {
                Label("Добавить упражнение", systemImage: "plus.circle.fill")
            }
        }
    }
    
    private var saveButtonSection: some View {
        Section {
            Button(isEditing ? "Сохранить шаблон" : "Создать шаблон") { saveTemplate() }
            .disabled(templateName.isBlank) // <--- СТРОКА 75: ИСПРАВЛЕНО
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                generalInfoSection
                exercisesSection
                saveButtonSection
            }
            .navigationTitle(navigationTitleString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Добавить") { saveTemplate() }
                    .disabled(templateName.isBlank) // <--- СТРОКА 88: ИСПРАВЛЕНО
                }
            }
            .sheet(isPresented: $showingSelectExerciseSheet) {
                SelectExerciseView() { selectedExercise in // SelectExerciseView должен быть обновлен
                    let newExerciseDetail = ExerciseTemplateDetail(exerciseID: selectedExercise.id, sets: [SetTemplate(setIndex: 1)])
                    templateExercises.append(newExerciseDetail)
                }
            }
            .onAppear {
                if !isEditing && selectedWorkoutTypeID == nil {
                    selectedWorkoutTypeID = bodyDataStore.workoutTypes.first?.id
                }
            }
        }
    }
    
    private func saveTemplate() { /* Твой код, использующий bodyDataStore */ dismiss() }
    private func deleteExerciseFromTemplate(at offsets: IndexSet) { templateExercises.remove(atOffsets: offsets) }
}

// Убедись, что это расширение String.isBlank существует и доступно
// (например, в Shared/Utils/StringExtension.swift или в конце этого файла)
extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct AddEditWorkoutTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditWorkoutTemplateView()
            .environmentObject(BodyDataStore.preview)
    }
}
