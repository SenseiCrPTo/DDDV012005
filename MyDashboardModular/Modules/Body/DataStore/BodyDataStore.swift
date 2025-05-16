import SwiftUI // Для @Published и ObservableObject

// Твои структуры WorkoutType, Exercise, WorkoutLog, BodyWeightLog, WorkoutTemplate, ExerciseLogDetail, SetTemplate
// должны быть определены где-то, чтобы этот DataStore компилировался.
// Я предполагаю, что они есть в соответствующих файлах в Modules/Body/Models/

class BodyDataStore: ObservableObject {
    @Published var workoutTypes: [WorkoutType] = []
    @Published var exercises: [Exercise] = []
    @Published var workoutLogs: [WorkoutLog] = []
    @Published var weightLogs: [BodyWeightLog] = []
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var targetWorkoutsPerWeek: Int = 3 // Это уже @Published, отлично!

    // Ключи для UserDefaults - остаются без изменений
    private let workoutTypesKey = "bodyApp_workoutTypes_vModular_1"
    private let exercisesKey = "bodyApp_exercises_vModular_1"
    private let workoutLogsKey = "bodyApp_workoutLogs_vModular_1"
    private let weightLogsKey = "bodyApp_weightLogs_vModular_1"
    private let workoutTemplatesKey = "bodyApp_workoutTemplates_vModular_1"
    private let targetWorkoutsKey = "bodyApp_targetWorkouts_vModular_1"

    init() {
        print("BodyDataStore: init started") // Добавил лог для отладки
        loadAllData()
        setupDefaultsIfNeeded()
        print("BodyDataStore: init finished. Weight logs: \(weightLogs.count), Workout Logs: \(workoutLogs.count), Target workouts: \(targetWorkoutsPerWeek)")
    }

    // MARK: - WorkoutType Management (Твой код остается без изменений)
    func addWorkoutType(name: String, iconName: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !workoutTypes.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) else { return }
        workoutTypes.append(WorkoutType(name: trimmedName, iconName: iconName))
        saveWorkoutTypes()
    }

    func updateWorkoutType(_ type: WorkoutType) {
        guard let index = workoutTypes.firstIndex(where: { $0.id == type.id }) else { return }
        workoutTypes[index] = type
        saveWorkoutTypes()
    }

    func deleteWorkoutType(id: UUID) {
        let isUsedInLogs = workoutLogs.contains { $0.workoutTypeID == id }
        let isUsedInTemplates = workoutTemplates.contains { $0.workoutTypeID == id }
        guard !isUsedInLogs && !isUsedInTemplates else {
            print("Cannot delete WorkoutType: it is in use in logs or templates.")
            return
        }
        workoutTypes.removeAll { $0.id == id }
        saveWorkoutTypes()
    }

    // MARK: - Exercise Management (Твой код остается без изменений)
    func addExercise(name: String, description: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !exercises.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) else { return }
        exercises.append(Exercise(name: trimmedName, description: description))
        saveExercises()
    }

    func updateExercise(_ exercise: Exercise) {
        guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        exercises[index] = exercise
        saveExercises()
    }

    func deleteExercise(id: UUID) {
        let isUsedInLogs = workoutLogs.contains { log in log.exercisesWithSets.contains { $0.exercise.id == id } }
        let isUsedInTemplates = workoutTemplates.contains { tmpl in tmpl.templateExercises.contains { $0.exerciseID == id } }
        guard !isUsedInLogs && !isUsedInTemplates else {
            print("Cannot delete Exercise: it is in use in logs or templates.")
            return
        }
        exercises.removeAll { $0.id == id }
        saveExercises()
    }

    // MARK: - WorkoutLog Management (Твой код остается без изменений)
    func logWorkout(_ log: WorkoutLog) {
        if let index = workoutLogs.firstIndex(where: { $0.id == log.id }) {
            workoutLogs[index] = log
        } else {
            workoutLogs.append(log)
        }
        workoutLogs.sort { $0.date > $1.date }
        saveWorkoutLogs()
    }

    func deleteWorkoutLog(id: UUID) {
        workoutLogs.removeAll { $0.id == id }
        saveWorkoutLogs()
    }

    // MARK: - BodyWeightLog Management (Твой код остается без изменений)
    func logWeight(kg: Double, date: Date = Date()) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        if let index = weightLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            weightLogs[index].weightInKg = kg // Убедись, что BodyWeightLog имеет свойство weightInKg
        } else {
            weightLogs.append(BodyWeightLog(date: startOfDay, weightInKg: kg))
        }
        weightLogs.sort { $0.date > $1.date }
        saveWeightLogs()
    }

    func deleteWeightLog(id: UUID) {
        weightLogs.removeAll { $0.id == id }
        saveWeightLogs()
    }

    // MARK: - WorkoutTemplate Management (Твой код остается без изменений)
    func addWorkoutTemplate(_ template: WorkoutTemplate) {
        guard !template.name.isEmpty, !workoutTemplates.contains(where: { $0.id == template.id || $0.name == template.name }) else { return }
        workoutTemplates.append(template)
        saveWorkoutTemplates()
    }

    func updateWorkoutTemplate(_ template: WorkoutTemplate) {
        guard let index = workoutTemplates.firstIndex(where: { $0.id == template.id }) else { return }
        workoutTemplates[index] = template
        saveWorkoutTemplates()
    }

    func deleteWorkoutTemplate(id: UUID) {
        workoutTemplates.removeAll { $0.id == id }
        saveWorkoutTemplates()
    }

    // MARK: - Creating Logs from Templates (Твой код остается без изменений)
    func createWorkoutLogFrom(template: WorkoutTemplate?) -> WorkoutLog {
        var exerciseDetails: [ExerciseLogDetail] = []
        var logNotes: String? = nil
        var logWorkoutTypeID: UUID? = nil

        if let template = template {
            logWorkoutTypeID = template.workoutTypeID
            logNotes = "Шаблон: \(template.name)"
            for templateDetail in template.templateExercises {
                if let exercise = exercises.first(where: { $0.id == templateDetail.exerciseID }) {
                    exerciseDetails.append(ExerciseLogDetail.from(templateDetail: templateDetail, exercise: exercise))
                }
            }
        }
        // Убедись, что конструктор WorkoutLog соответствует
        return WorkoutLog(date: Date(), workoutTypeID: logWorkoutTypeID, exercisesWithSets: exerciseDetails, notes: logNotes)
    }

    // MARK: - Computed Properties for UI (Твой код остается без изменений)
    // Убедись, что эти свойства корректно работают и возвращают нужные строки/числа
    var currentWeightString: String {
        (weightLogs.first?.weightInKg).map { String(format: "%.1f кг", $0) } ?? "-- кг"
    }

    var totalTrainingDays: Int {
        Set(workoutLogs.map { Calendar.current.startOfDay(for: $0.date) }).count
    }

    var favoriteWorkoutType: WorkoutType? {
        if workoutLogs.isEmpty { return nil }
        let typeCounts = Dictionary(grouping: workoutLogs.compactMap { $0.workoutTypeID }, by: { $0 })
            .mapValues { $0.count }
        guard let mostFrequentID = typeCounts.max(by: { $0.value < $1.value })?.key else { return nil }
        return workoutTypes.first { $0.id == mostFrequentID }
    }

    var favoriteWorkoutTypeName: String {
        favoriteWorkoutType?.name ?? "Нет данных"
    }

    var workoutsThisWeekCount: Int {
        let calendar = Calendar.current
        let now = Date()
        // Используем guard для безопасного развертывания опционалов
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }

        let uniqueTrainingDaysThisWeek = Set(
            workoutLogs
                .filter { weekInterval.contains($0.date) }
                .map { calendar.startOfDay(for: $0.date) }
        )
        return uniqueTrainingDaysThisWeek.count
    }

    // MARK: - Persistence (Твой код остается без изменений, но objectWillChange.send() лучше вызывать после изменения данных)
    // Я убрал objectWillChange.send() из методов save, так как @Published свойства уже делают это автоматически.
    // Если ты добавлял их для какой-то специфической цели, можешь вернуть.
    private func saveData<T: Codable>(_ data: T, key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            print("BodyDataStore Error: Error encoding \(key) for type \(T.self)")
        }
    }

    private func loadData<T: Codable>(key: String) -> T? {
        guard let savedData = UserDefaults.standard.data(forKey: key) else { return nil }
        if let decodedData = try? JSONDecoder().decode(T.self, from: savedData) {
            return decodedData
        } else {
            print("BodyDataStore Error: Error decoding \(key) for type \(T.self). Data for this key might be corrupted.")
            // UserDefaults.standard.removeObject(forKey: key) // Опционально: удалять поврежденные данные
            return nil
        }
    }

    func saveWorkoutTypes() { saveData(workoutTypes, key: workoutTypesKey) }
    func loadWorkoutTypes() { if let loaded: [WorkoutType] = loadData(key: workoutTypesKey) { self.workoutTypes = loaded } else { self.workoutTypes = [] } }

    func saveExercises() { saveData(exercises, key: exercisesKey) }
    func loadExercises() { if let loaded: [Exercise] = loadData(key: exercisesKey) { self.exercises = loaded } else { self.exercises = [] } }

    func saveWorkoutLogs() { saveData(workoutLogs, key: workoutLogsKey) }
    func loadWorkoutLogs() { if let loaded: [WorkoutLog] = loadData(key: workoutLogsKey) { self.workoutLogs = loaded.sorted { $0.date > $1.date } } else { self.workoutLogs = [] } }

    func saveWeightLogs() { saveData(weightLogs, key: weightLogsKey) }
    func loadWeightLogs() { if let loaded: [BodyWeightLog] = loadData(key: weightLogsKey) { self.weightLogs = loaded.sorted { $0.date > $1.date } } else { self.weightLogs = [] } }

    func saveWorkoutTemplates() { saveData(workoutTemplates, key: workoutTemplatesKey) }
    func loadWorkoutTemplates() { if let loaded: [WorkoutTemplate] = loadData(key: workoutTemplatesKey) { self.workoutTemplates = loaded } else { self.workoutTemplates = [] } }

    func saveTargetWorkouts() { UserDefaults.standard.set(targetWorkoutsPerWeek, forKey: targetWorkoutsKey) }
    func loadTargetWorkouts() {
        if UserDefaults.standard.object(forKey: targetWorkoutsKey) != nil {
            self.targetWorkoutsPerWeek = UserDefaults.standard.integer(forKey: targetWorkoutsKey)
            if self.targetWorkoutsPerWeek == 0 && !UserDefaults.standard.bool(forKey: "\(targetWorkoutsKey)_wasSetToZero") { // Проверка, не было ли 0 установлено пользователем
                 self.targetWorkoutsPerWeek = 3 // Восстанавливаем дефолт, если 0 не был установлен явно
            }
        } else {
            self.targetWorkoutsPerWeek = 3 // Дефолтное значение, если ключ вообще отсутствует
        }
    }
    
    func setTargetWorkoutsExplicitly(count: Int) { // Метод для явной установки, в т.ч. 0
        self.targetWorkoutsPerWeek = max(0, count)
        UserDefaults.standard.set(self.targetWorkoutsPerWeek == 0, forKey: "\(targetWorkoutsKey)_wasSetToZero")
        saveTargetWorkouts()
    }


    func loadAllData() {
        loadWorkoutTypes()
        loadExercises()
        loadWorkoutLogs()
        loadWeightLogs()
        loadWorkoutTemplates()
        loadTargetWorkouts()
    }

    func setupDefaultsIfNeeded() {
        var didSetupSomething = false
        if UserDefaults.standard.data(forKey: workoutTypesKey) == nil && workoutTypes.isEmpty { setupDefaultWorkoutTypes(); didSetupSomething = true }
        if UserDefaults.standard.data(forKey: exercisesKey) == nil && exercises.isEmpty { setupDefaultExercises(); didSetupSomething = true }
        if UserDefaults.standard.data(forKey: weightLogsKey) == nil && weightLogs.isEmpty { setupDefaultWeightLog(); didSetupSomething = true }
        
        if UserDefaults.standard.data(forKey: workoutLogsKey) == nil && workoutLogs.isEmpty && !workoutTypes.isEmpty && !exercises.isEmpty { setupDefaultWorkoutLog(); didSetupSomething = true }
        if UserDefaults.standard.data(forKey: workoutTemplatesKey) == nil && workoutTemplates.isEmpty && !workoutTypes.isEmpty && !exercises.isEmpty { setupDefaultWorkoutTemplate(); didSetupSomething = true }
        
        // Установка targetWorkoutsPerWeek по умолчанию, если он еще не был загружен или установлен
        if UserDefaults.standard.object(forKey: targetWorkoutsKey) == nil {
             self.targetWorkoutsPerWeek = 3
             saveTargetWorkouts() // Сохраняем дефолтное значение
             didSetupSomething = true
        }

        if didSetupSomething {
            // objectWillChange.send() // Не обязательно, если setupDefault... методы вызывают save...(), которые вызывают objectWillChange через @Published
            print("BodyDataStore: Default data setup completed.")
        }
    }

    // Твои setupDefault... методы остаются без изменений
    private func setupDefaultWorkoutTypes() { self.workoutTypes = [WorkoutType(name: "Зал", iconName: "figure.gym.symbol"), WorkoutType(name: "Йога", iconName: "figure.yoga"), WorkoutType(name: "Бег", iconName: "figure.run"), WorkoutType(name: "Силовая", iconName: "figure.strengthtraining.traditional"), WorkoutType(name: "Кардио", iconName: "figure.jumprope")]; saveWorkoutTypes(); print("Default WorkoutTypes SET") }
    private func setupDefaultExercises() { self.exercises = [Exercise(name: "Приседания со штангой"), Exercise(name: "Жим лежа"), Exercise(name: "Становая тяга"), Exercise(name: "Подтягивания"), Exercise(name: "Отжимания"), Exercise(name: "Планка"), Exercise(name: "Бег на дорожке"), Exercise(name: "Велотренажер"), Exercise(name: "Приветствие Солнцу")]; saveExercises(); print("Default Exercises SET") }
    private func setupDefaultWeightLog() { self.weightLogs = [BodyWeightLog(weightInKg: 75.0)]; saveWeightLogs(); print("Default WeightLog SET") }
    private func setupDefaultWorkoutLog() { guard let g = workoutTypes.first(where: { $0.name == "Зал" }), let sq = exercises.first(where: { $0.name == "Приседания со штангой" }), let bp = exercises.first(where: { $0.name == "Жим лежа" }) else { return }; logWorkout(WorkoutLog(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, workoutTypeID: g.id, duration: 3600, exercisesWithSets: [ExerciseLogDetail(exercise: sq, sets: [WorkoutSet(exerciseID: sq.id, setIndex: 1, reps: 10, weight: 60, isCompleted: true), WorkoutSet(exerciseID: sq.id, setIndex: 2, reps: 8, weight: 65, isCompleted: true)]), ExerciseLogDetail(exercise: bp, sets: [WorkoutSet(exerciseID: bp.id, setIndex: 1, reps: 10, weight: 50, isCompleted: true)])], notes: "Пример прошлой тренировки")); print("Default WorkoutLog SET") }
    private func setupDefaultWorkoutTemplate() { guard let sID = exercises.first(where: { $0.name == "Приседания со штангой" })?.id, let bID = exercises.first(where: { $0.name == "Жим лежа" })?.id, let pID = exercises.first(where: { $0.name == "Подтягивания" })?.id, let strID = workoutTypes.first(where: { $0.name == "Силовая" })?.id else { return }; addWorkoutTemplate(WorkoutTemplate(name: "Базовая 3х8-12", workoutTypeID: strID, templateExercises: [ExerciseTemplateDetail(exerciseID: sID, sets: [SetTemplate(setIndex: 1), SetTemplate(setIndex: 2), SetTemplate(setIndex: 3)]), ExerciseTemplateDetail(exerciseID: bID, sets: [SetTemplate(setIndex: 1), SetTemplate(setIndex: 2), SetTemplate(setIndex: 3)]), ExerciseTemplateDetail(exerciseID: pID, sets: [SetTemplate(setIndex: 1, targetReps: "MAX"), SetTemplate(setIndex: 2, targetReps: "MAX"), SetTemplate(setIndex: 3, targetReps: "MAX")])])); print("Default WorkoutTemplate SET") }


    // MARK: - Static Preview Instance
    /// Статический экземпляр для использования в SwiftUI Previews.
    static var preview: BodyDataStore = {
        let dataStore = BodyDataStore() // Создает экземпляр с вызовом init()
        
        // Убедимся, что есть какие-то данные для отображения в превью,
        // особенно если setupDefaultsIfNeeded() не сработал (например, ключи уже существовали, но с пустыми данными).
        if dataStore.weightLogs.isEmpty {
            dataStore.logWeight(kg: 77.7, date: Date().addingTimeInterval(-86400 * 2)) // Добавим лог веса для превью
        }
        if dataStore.workoutLogs.isEmpty {
            // Попробуем добавить дефолтную тренировку, если есть типы и упражнения
            if let type = dataStore.workoutTypes.first, let exercise = dataStore.exercises.first {
                 dataStore.logWorkout(
                    WorkoutLog(
                        date: Date().addingTimeInterval(-86400 * 1), // Вчера
                        workoutTypeID: type.id,
                        duration: 2700, // 45 минут
                        exercisesWithSets: [
                            ExerciseLogDetail(
                                exercise: exercise,
                                sets: [WorkoutSet(exerciseID: exercise.id, setIndex: 1, reps: 10, weight: 50, isCompleted: true)]
                            )
                        ],
                        notes: "Тренировка для превью"
                    )
                 )
            }
        }
        // Устанавливаем targetWorkoutsPerWeek, если он не был установлен
        // (хотя loadTargetWorkouts и setupDefaultsIfNeeded должны это сделать)
        if dataStore.targetWorkoutsPerWeek == 0 && !UserDefaults.standard.bool(forKey: "\(dataStore.targetWorkoutsKey)_wasSetToZero") {
            dataStore.targetWorkoutsPerWeek = 3 // Типичное значение по умолчанию
        }
        print("BodyDataStore.preview: Weight logs: \(dataStore.weightLogs.count), Workout Logs: \(dataStore.workoutLogs.count), Target: \(dataStore.targetWorkoutsPerWeek)")
        return dataStore
    }()
}

// Убедись, что определения структур WorkoutType, Exercise, WorkoutLog, BodyWeightLog, WorkoutTemplate,
// ExerciseLogDetail, SetTemplate существуют и являются Codable & Identifiable (если нужно).
// Например:
/*
struct WorkoutType: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var iconName: String?
}
struct Exercise: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String?
}
struct BodyWeightLog: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var weightInKg: Double
}
struct WorkoutLog: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var workoutTypeID: UUID? // Связь с WorkoutType
    var duration: TimeInterval? // Общая длительность
    var exercisesWithSets: [ExerciseLogDetail] = []
    var notes: String?
    // ... другие поля ...
}
struct ExerciseLogDetail: Identifiable, Codable, Hashable {
    var id = UUID()
    var exercise: Exercise // Полный объект Exercise для удобства (или только ID и подгружать)
    var sets: [WorkoutSet] = []

    static func from(templateDetail: ExerciseTemplateDetail, exercise: Exercise) -> ExerciseLogDetail {
        // Логика преобразования из шаблона упражнения в лог упражнения
        let logSets = templateDetail.sets.map { WorkoutSet.from(templateSet: $0, exerciseID: exercise.id) }
        return ExerciseLogDetail(exercise: exercise, sets: logSets)
    }
}
struct WorkoutSet: Identifiable, Codable, Hashable {
    var id = UUID()
    var exerciseID: UUID // Ссылка на упражнение, к которому принадлежит этот подход
    var setIndex: Int
    var reps: Int?
    var targetReps: String? // Может быть "MAX" или диапазон "8-12"
    var weight: Double?
    var duration: TimeInterval? // Для упражнений на время
    var distance: Double? // Для кардио
    var isCompleted: Bool = false
    var notes: String?

    static func from(templateSet: SetTemplate, exerciseID: UUID) -> WorkoutSet {
        // Логика преобразования из шаблона подхода в лог подхода
        // Здесь можно установить isCompleted = false по умолчанию
        return WorkoutSet(exerciseID: exerciseID, setIndex: templateSet.setIndex, targetReps: templateSet.targetReps, weight: templateSet.targetWeight)
    }
}
struct WorkoutTemplate: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var workoutTypeID: UUID?
    var templateExercises: [ExerciseTemplateDetail] = []
    var notes: String?
}
struct ExerciseTemplateDetail: Identifiable, Codable, Hashable {
    var id = UUID()
    var exerciseID: UUID
    var sets: [SetTemplate] = []
    var restTimeBetweenSets: TimeInterval? // в секундах
}
struct SetTemplate: Identifiable, Codable, Hashable {
    var id = UUID()
    var setIndex: Int
    var targetReps: String? // "8-12", "MAX", "10"
    var targetWeight: Double?
    var targetDuration: TimeInterval?
    var notes: String?
}
*/
