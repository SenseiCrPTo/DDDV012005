import SwiftUI

struct EditExerciseTemplateDetailView: View {
    @Binding var exerciseDetail: ExerciseTemplateDetail
    @EnvironmentObject var bodyDataStore: BodyDataStore

    @State private var showingEditSetSheet = false
    @State private var setToEdit: SetTemplate? = nil
    @State private var editingSetIndex: Int? = nil

    private var exerciseName: String {
        bodyDataStore.exercises.first { $0.id == exerciseDetail.exerciseID }?.name ?? "Неизвестное упражнение"
    }

    var body: some View {
        Form {
            Section(header: Text("Упражнение: \(exerciseName)")) {
                if exerciseDetail.sets.isEmpty {
                    Text("Нет подходов. Нажмите \"+\", чтобы добавить.")
                        .foregroundColor(.gray)
                } else {
                    ForEach($exerciseDetail.sets) { $setBinding in
                        HStack {
                            Text(setBinding.displayString)
                            Spacer()
                            Button {
                                if let index = exerciseDetail.sets.firstIndex(where: { $0.id == setBinding.id }) {
                                    self.editingSetIndex = index
                                    self.setToEdit = $setBinding.wrappedValue // Копируем для редактирования, если нужно
                                    self.showingEditSetSheet = true
                                }
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteSet)
                }

                Button {
                    self.editingSetIndex = nil
                    let newSetIndexValue = (exerciseDetail.sets.last?.setIndex ?? 0) + 1
                    self.setToEdit = SetTemplate(setIndex: newSetIndexValue)
                    self.showingEditSetSheet = true
                } label: {
                    Label("Добавить подход", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Настроить упражнение")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSetSheet) {
            if let index = editingSetIndex, index < exerciseDetail.sets.count {
                // Редактирование существующего
                EditSetTemplateView(setTemplate: $exerciseDetail.sets[index])
            } else if let initialNewSet = setToEdit, editingSetIndex == nil { // ИСПРАВЛЕНО: используем initialNewSet
                // Создание нового
                EditSetTemplateViewWithSave(
                    initialSetTemplate: initialNewSet, // Передаем наш новый, но еще не добавленный сет
                    onSave: { finalSetTemplate in
                        exerciseDetail.sets.append(finalSetTemplate)
                        self.setToEdit = nil
                        self.showingEditSetSheet = false
                    },
                    onCancel: {
                        self.setToEdit = nil
                        self.showingEditSetSheet = false
                    }
                )
            }
        }
    }
        
    private func deleteSet(at offsets: IndexSet) {
        exerciseDetail.sets.remove(atOffsets: offsets)
    }
}

// EditSetTemplateViewWithSave остается как в предыдущем ответе
struct EditSetTemplateViewWithSave: View {
    @State var setTemplate: SetTemplate
    var onSave: (SetTemplate) -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) var dismiss

    @State private var targetRepsString: String
    @State private var targetWeightString: String
    @State private var targetDurationString: String
    @State private var targetRestTimeString: String
    
    init(initialSetTemplate: SetTemplate, onSave: @escaping (SetTemplate) -> Void, onCancel: @escaping () -> Void) {
        self._setTemplate = State(initialValue: initialSetTemplate)
        self.onSave = onSave
        self.onCancel = onCancel

        self._targetRepsString = State(initialValue: initialSetTemplate.targetReps ?? "8-12")
        self._targetWeightString = State(initialValue: initialSetTemplate.targetWeight.map { String(format: "%.1f", $0) } ?? "")
        self._targetDurationString = State(initialValue: initialSetTemplate.targetDuration.map { String(Int($0)) } ?? "")
        self._targetRestTimeString = State(initialValue: initialSetTemplate.targetRestTime.map { String(Int($0)) } ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                 Section("Параметры подхода \(setTemplate.setIndex)") {
                    TextField("Целевые повторения (напр. 8-12, AMRAP)", text: $targetRepsString)
                    HStack {
                        Text("Целевой вес (кг):")
                        TextField("0.0", text: $targetWeightString).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Целевая длит. (сек):")
                        TextField("0", text: $targetDurationString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Отдых после (сек):")
                        TextField("0", text: $targetRestTimeString).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle(setTemplate.id == SetTemplate(setIndex: setTemplate.setIndex).id && targetRepsString == (SetTemplate(setIndex: setTemplate.setIndex).targetReps ?? "8-12") ? "Новый подход" : "Редакт. подход")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { onCancel(); /* dismiss() вызывается в onCancel в родительском View через showingEditSetSheet = false */ }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        applyChangesToStateSet()
                        onSave(setTemplate)
                        // dismiss() // dismiss будет вызван в onSave/onCancel в родительском View
                    }
                }
            }
        }
    }
    
    private func applyChangesToStateSet() {
        setTemplate.targetReps = targetRepsString.isEmpty ? nil : targetRepsString
        setTemplate.targetWeight = Double(targetWeightString.replacingOccurrences(of: ",", with: "."))
        if let durationInt = Int(targetDurationString), durationInt >= 0 { setTemplate.targetDuration = TimeInterval(durationInt) } else { setTemplate.targetDuration = nil }
        if let restInt = Int(targetRestTimeString), restInt >= 0 { setTemplate.targetRestTime = TimeInterval(restInt) } else { setTemplate.targetRestTime = nil }
    }
}
