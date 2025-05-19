import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var bodyDataStore: BodyDataStore // <--- ИЗМЕНЕНО
    @Binding var activeWorkoutLog: WorkoutLog?
    @Environment(\.dismiss) var dismiss

    @State private var localLog: WorkoutLog
    @State private var startTime: Date

    @State private var showingSelectExerciseSheet = false

    // init БУДЕТ УБРАН, если bodyDataStore передается через @EnvironmentObject
    // Если он был только для @ObservedObject, то теперь SwiftUI позаботится об этом.
    // Если были другие параметры в init, их нужно оставить.
    // Твой текущий init:
    init(workoutLogBinding: Binding<WorkoutLog?>) { // <--- УБРАН bodyDataStore из параметров
        self._activeWorkoutLog = workoutLogBinding

        if let currentLog = workoutLogBinding.wrappedValue {
            self._localLog = State(initialValue: currentLog)
            self._startTime = State(initialValue: currentLog.date)
        } else {
            // Эта ситуация не должна возникать, если BodyMiniAppView всегда создает лог перед переходом.
            // Для безопасности, создаем "пустой" лог, но это может потребовать BodyDataStore.
            // Если bodyDataStore здесь нужен для createWorkoutLogFrom, его придется получать из @EnvironmentObject
            // или передавать createWorkoutLogFrom как замыкание.
            // Поскольку BodyDataStore теперь в @EnvironmentObject, мы можем его использовать.
            // НО! Нельзя использовать @EnvironmentObject внутри init(), он еще не доступен.
            // Поэтому, если workoutLogBinding.wrappedValue == nil, это проблема логики вызова.
            // Для отладки, пока оставим создание временного лога, но это нужно будет исправить.
            print("ActiveWorkoutView WARNING: workoutLogBinding was nil. Creating a temporary new log.")
            let tempNewLog = WorkoutLog(date: Date(), exercisesWithSets: []) // Упрощенный временный лог
            self._localLog = State(initialValue: tempNewLog)
            self._startTime = State(initialValue: tempNewLog.date)
            // В этом случае, при сохранении, мы должны будем добавить его в DataStore как новый.
        }
    }
    
    // Если localLog будет инициализироваться в .onAppear, то init может быть проще:
    /*
    init(workoutLogBinding: Binding<WorkoutLog?>) {
        self._activeWorkoutLog = workoutLogBinding
        // Инициализация localLog и startTime переносится в .onAppear
        // Здесь нужно задать им временные значения, чтобы @State скомпилировались
        self._localLog = State(initialValue: WorkoutLog(date: Date(), exercisesWithSets: []))
        self._startTime = State(initialValue: Date())
    }
    */


    var body: some View {
        Form {
            Section {
                Picker("Тип тренировки", selection: $localLog.workoutTypeID) {
                    Text("Не выбрано").tag(nil as UUID?)
                    ForEach(bodyDataStore.workoutTypes) { type in
                        Text(type.name).tag(type.id as UUID?)
                    }
                }
                DatePicker("Начало тренировки", selection: $startTime)

                TextField("Заметки к тренировке", text: Binding(
                    get: { localLog.notes ?? "" },
                    set: { localLog.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3...)
            }

            ForEach($localLog.exercisesWithSets) { $exerciseDetailEntry in
                // ExerciseDetailSectionView должен быть обновлен для @EnvironmentObject, если он использует bodyDataStore
                ExerciseDetailSectionView(exerciseDetail: $exerciseDetailEntry)
            }
            .onDelete(perform: deleteExerciseDetail)

            Button {
                showingSelectExerciseSheet = true
            } label: {
                Label("Добавить упражнение", systemImage: "plus.circle.fill")
            }
        }
        .navigationTitle(localLog.id == activeWorkoutLog?.id && activeWorkoutLog != nil ? "Редактирование" : "Новая тренировка") // Улучшенный заголовок
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Отмена") { cancelWorkout() }.tint(.red)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(localLog.id == activeWorkoutLog?.id && activeWorkoutLog != nil && bodyDataStore.workoutLogs.contains(where: {$0.id == localLog.id}) ? "Сохранить" : "Завершить") { // Более точное название кнопки
                    finishWorkout()
                }
                .tint(.green)
            }
        }
        .sheet(isPresented: $showingSelectExerciseSheet) {
            // SelectExerciseView должен быть обновлен для @EnvironmentObject
            SelectExerciseView() { selectedExercise in
                addExerciseToLog(selectedExercise)
            }
        }
        .onAppear {
             // Эта логика нужна, если мы не инициализируем localLog полностью в init,
             // или чтобы гарантировать синхронизацию, если activeWorkoutLog может измениться извне
             // (хотя с @Binding это обычно не так).
            if let currentBoundLog = activeWorkoutLog {
                if localLog.id != currentBoundLog.id { // Если лог изменился (например, при переходе с nil на реальный)
                    localLog = currentBoundLog
                }
                startTime = localLog.date // Всегда синхронизируем startTime с датой лога при появлении
            } else {
                // Если activeWorkoutLog все еще nil (не должно быть при правильном вызове),
                // создаем новый и устанавливаем его.
                let newLog = bodyDataStore.createWorkoutLogFrom(template: nil)
                localLog = newLog
                startTime = newLog.date
                activeWorkoutLog = newLog // Обновляем внешний binding
                print("ActiveWorkoutView onAppear: activeWorkoutLog был nil, создан новый.")
            }
        }
    }

    private func deleteExerciseDetail(at offsets: IndexSet) {
        localLog.exercisesWithSets.remove(atOffsets: offsets)
    }

    private func addExerciseToLog(_ exercise: Exercise) {
        // Убедись, что WorkoutSet инициализируется правильно
        localLog.exercisesWithSets.append(ExerciseLogDetail(exercise: exercise, sets: [WorkoutSet(exerciseID: exercise.id, setIndex: 1)]))
    }

    private func cancelWorkout() {
        // Если это был новый, несохраненный лог, его не нужно удалять из DataStore
        // Если это был редактируемый лог, изменения в localLog не сохранятся
        activeWorkoutLog = nil
        dismiss()
    }

    private func finishWorkout() {
        guard activeWorkoutLog != nil else { // Если лога не было (маловероятно), то это ошибка логики
            dismiss()
            return
        }
        localLog.date = startTime
        localLog.duration = Date().timeIntervalSince(startTime)

        bodyDataStore.logWorkout(localLog) // Этот метод должен либо добавлять новый, либо обновлять существующий

        activeWorkoutLog = nil
        dismiss()
    }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        // Для превью нужно создать моковый State для Binding
        // Пример для новой тренировки
        StatefulPreviewWrapper_ActiveWorkout_New()
        
        // Пример для редактирования существующей
        StatefulPreviewWrapper_ActiveWorkout_Edit()
    }
}

// Вспомогательные структуры для превью с @State/@Binding
private struct StatefulPreviewWrapper_ActiveWorkout_New: View {
    @State private var workoutLog: WorkoutLog? = nil // Начинаем с nil, onAppear создаст новый
    static var dataStore = BodyDataStore.preview // Используем один dataStore для всех превью этой группы

    var body: some View {
        NavigationView {
            ActiveWorkoutView(workoutLogBinding: $workoutLog)
                .environmentObject(Self.dataStore)
        }
        .onAppear { // Инициализируем лог здесь, чтобы @EnvironmentObject был доступен
            if workoutLog == nil {
                workoutLog = Self.dataStore.createWorkoutLogFrom(template: nil)
            }
        }
    }
}

private struct StatefulPreviewWrapper_ActiveWorkout_Edit: View {
    @State private var workoutLog: WorkoutLog?
    static var dataStore = BodyDataStore.preview

    init() {
        // Создаем или берем существующий лог для редактирования
        if let firstLog = Self.dataStore.workoutLogs.first {
            _workoutLog = State(initialValue: firstLog)
        } else {
            let sampleLog = Self.dataStore.createWorkoutLogFrom(template: nil) // Создаем какой-то для примера
            // Self.dataStore.logWorkout(sampleLog) // Не обязательно добавлять в store для превью, если это не требуется
            _workoutLog = State(initialValue: sampleLog)
        }
    }

    var body: some View {
        NavigationView {
            ActiveWorkoutView(workoutLogBinding: $workoutLog)
                .environmentObject(Self.dataStore)
        }
    }
}
