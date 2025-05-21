import SwiftUI
import Combine

class HabitDataStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var habitLogs: [HabitLog] = [] // Убедись, что структура HabitLog определена корректно

    // Используем разные ключи для избежания конфликтов со старыми данными при отладке
    private let habitsKey = "habits_v1.1.0"
    private let habitLogsKey = "habitLogs_v1.1.0"

    init() {
        print("HabitDataStore: Инициализация...")
        loadHabits()
        loadHabitLogs()

        // Загружаем примеры только если НЕТ сохраненных данных по текущему ключу habitsKey
        if UserDefaults.standard.data(forKey: habitsKey) == nil {
            print("HabitDataStore: Нет сохраненных привычек по ключу '\(habitsKey)'. Создание примеров.")
            setupSampleHabits() // Это сохранит их
        } else {
            // Если данные были загружены, просто отсортируем их
            if !habits.isEmpty {
                 print("HabitDataStore: Привычки загружены (\(habits.count)). Сортировка.")
                 sortHabits()
            } else {
                 print("HabitDataStore: Данные по ключу '\(habitsKey)' есть, но массив habits пуст после загрузки. Возможно, данные повреждены или пусты.")
            }
        }
        print("HabitDataStore: Инициализация завершена. Привычек: \(habits.count), Логов: \(habitLogs.count).")
    }

    // MARK: - Habit Management
    func addHabit(name: String, description: String? = nil, iconName: String, colorHex: String,
                  frequency: HabitFrequency = .daily,
                  goalCount: Int? = nil, goalTargetCount: Int = 1, goalDuration: TimeInterval? = nil,
                  showOnWidget: Bool = false, reminderTime: Date? = nil, reminderDays: Set<Int>? = nil) {
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            print("HabitDataStore Error: Имя привычки не может быть пустым.");
            return
        }
        
        if habits.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame && !$0.isArchived }) {
            print("HabitDataStore Warning: Активная привычка с именем '\(trimmedName)' уже существует.");
            // В реальном приложении здесь можно показать пользователю alert
            return
        }
        
        let newHabit = Habit(name: trimmedName, description: description, iconName: iconName, colorHex: colorHex,
                             frequency: frequency, goalCount: goalCount, goalTargetCount: goalTargetCount,
                             goalDuration: goalDuration, showOnWidget: showOnWidget, creationDate: Date(),
                             reminderTime: reminderTime, reminderDays: reminderDays, isArchived: false)
        habits.append(newHabit)
        sortHabits()
        saveHabits()
        print("HabitDataStore: Добавлена привычка '\(newHabit.name)' ID: \(newHabit.id)")
    }

    func updateHabit(_ habitToUpdate: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habitToUpdate.id }) else {
            print("HabitDataStore Error: Привычка с ID \(habitToUpdate.id) для обновления не найдена.")
            return
        }
        let trimmedName = habitToUpdate.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if habits.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame && $0.id != habitToUpdate.id && !$0.isArchived }) {
            print("HabitDataStore Warning: Другая активная привычка с именем '\(trimmedName)' уже существует. Обновление отменено.")
            return
        }
        
        habits[index] = habitToUpdate
        sortHabits() // Сортировка может быть нужна, если изменились поля, влияющие на нее
        saveHabits()
        print("HabitDataStore: Обновлена привычка '\(habitToUpdate.name)' ID: \(habitToUpdate.id)")
    }
    
    /// Удаляет привычку и связанные с ней логи по указанным смещениям.
    /// ВАЖНО: `offsets` должны относиться к текущему состоянию массива `habits` в `HabitDataStore`.
    /// Этот метод следует использовать с осторожностью, если `offsets` приходят из отфильтрованного списка.
    func deleteHabit(at offsets: IndexSet) {
        guard !offsets.isEmpty else { return }
        print("HabitDataStore: Попытка удаления по смещениям (offsets): \(offsets) из общего массива habits (\(habits.count) элементов)")

        // Создаем массив ID для удаления логов ДО изменения массива habits
        // и для проверки, что индексы не выходят за пределы
        var idsToDeleteLogs: [UUID] = []
        for index in offsets {
            if habits.indices.contains(index) {
                idsToDeleteLogs.append(habits[index].id)
            } else {
                print("HabitDataStore Error: Индекс \(index) вне диапазона для удаления.")
                // Можно либо прервать операцию, либо пропустить этот индекс
                // Для безопасности, лучше прервать, если ожидаются точные индексы
                return
            }
        }
        
        idsToDeleteLogs.forEach { habitID in
            habitLogs.removeAll { $0.habitID == habitID }
            print("HabitDataStore: Удалены логи для привычки ID \(habitID)")
        }
        
        habits.remove(atOffsets: offsets)
        // sortHabits() // Сортировка после удаления не обязательна, порядок сохраняется
        saveHabits()
        saveHabitLogs()
        print("HabitDataStore: Привычки удалены по смещениям. Осталось: \(habits.count)")
    }

    /// Более безопасный метод удаления привычки и связанных логов по ее уникальному ID.
    func deleteHabitById(_ id: UUID) {
        if let index = habits.firstIndex(where: { $0.id == id }) {
            let habitName = habits[index].name
            habits.remove(at: index)
            habitLogs.removeAll { $0.habitID == id }
            // sortHabits() // Не обязательно после удаления по ID
            saveHabits()
            saveHabitLogs()
            print("HabitDataStore: Удалена привычка '\(habitName)' (ID: \(id))")
        } else {
            print("HabitDataStore Warning: Попытка удаления несуществующей привычки с ID: \(id)")
        }
    }
    
    func archiveHabit(_ habit: Habit, shouldArchive: Bool) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].isArchived = shouldArchive
        sortHabits() // Важно для перемещения между активными и архивными
        saveHabits()
    }

    private func sortHabits() {
        habits.sort {
            if $0.isArchived != $1.isArchived { return !$0.isArchived }
            if $0.showOnWidget != $1.showOnWidget { return $0.showOnWidget }
            return $0.creationDate < $1.creationDate // Или по имени: $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    private func setupSampleHabits() {
        print("HabitDataStore: Вызов setupSampleHabits() для заполнения пустыми данными.")
        let hexBlue = Color.blue.toHex() ?? "007AFF"
        let hexGreen = Color.green.toHex() ?? "34C759"
        let hexOrange = Color.orange.toHex() ?? "FF9500"
        let hexCyan = Color.cyan.toHex() ?? "30B0C7"
        let hexRed = Color.red.toHex() ?? "FF3B30"
        
        let sampleHabitsList: [Habit] = [
            Habit(name: "Утренняя зарядка", iconName: "figure.walk", colorHex: hexGreen, frequency: .daily, goalDuration: 15*60, showOnWidget: true),
            Habit(name: "Читать 20 страниц", iconName: "book.fill", colorHex: hexBlue, frequency: .daily, goalTargetCount: 20, showOnWidget: true),
            Habit(name: "Медитация 10 мин", iconName: "brain.head.profile", colorHex: hexOrange, frequency: .specificDaysOfWeek(days: [Calendar.current.component(.weekday, from: Date()), (Calendar.current.component(.weekday, from: Date()) % 7) + 1 ]), goalDuration: 10*60, showOnWidget: true), // Пример дней
            Habit(name: "Пить 8 стаканов воды", iconName: "drop.fill", colorHex: hexCyan, frequency: .daily, goalTargetCount: 8, showOnWidget: true),
            Habit(name: "Без сладкого", iconName: "nosign", colorHex: hexRed, frequency: .daily),
            Habit(name: "Занятие спортом", iconName: "dumbbell.fill", colorHex: "5856D6", frequency: .timesPerWeek(count: 3)),
            Habit(name: "Полить цветы", iconName: "leaf.fill", colorHex: "A2845E", frequency: .everyXDays(days: 3))
        ]

        // Добавляем только если их еще нет (проверка по имени для простоты примера)
        // В идеале, setupSampleHabits должен вызываться только один раз при первой установке.
        // Логика в init теперь это учитывает через проверку UserDefaults.standard.data(forKey: habitsKey) == nil
        self.habits.append(contentsOf: sampleHabitsList)
        sortHabits()
        saveHabits() // Сохраняем созданные примеры
        print("HabitDataStore: Примерные привычки созданы и сохранены, всего: \(self.habits.count)")
    }

    // MARK: - HabitLog Management
    func logHabitCompletion(habitID: UUID, date: Date, isCompleted: Bool = true, notes: String? = nil, duration: TimeInterval? = nil, countAchieved: Int? = nil) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let index = habitLogs.firstIndex(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) }) {
            // Обновляем существующий лог
            habitLogs[index].isCompleted = isCompleted
            habitLogs[index].notes = notes ?? habitLogs[index].notes // Сохраняем старые заметки, если новые не переданы
            if let duration = duration {
                 // Если цель - накопление времени, то добавляем. Если перезапись, то просто присваиваем.
                 // Пока сделаем добавление, если уже было значение.
                habitLogs[index].loggedDuration = (habitLogs[index].loggedDuration ?? 0) + duration
            } else if isCompleted == false { // Если отменяем выполнение, сбросим и длительность
                habitLogs[index].loggedDuration = nil
            }
            habitLogs[index].completedTimestamp = isCompleted ? Date() : nil
            // Обновление countAchieved для лога, если нужно
        } else if isCompleted { // Создаем новый лог только если isCompleted = true
            habitLogs.append(HabitLog(habitID: habitID, date: normalizedDate, isCompleted: isCompleted, notes: notes, completedTimestamp: Date(), loggedDuration: duration))
        }

        // Обновление прогресса в самой привычке (goalCount)
        if let habitIndex = habits.firstIndex(where: { $0.id == habitID }) {
            if habits[habitIndex].goalTargetCount > 1 && habits[habitIndex].goalCount != nil { // Если это количественная цель
                if isCompleted {
                    if let achieved = countAchieved { // Если передан конкретный новый счетчик
                        habits[habitIndex].goalCount = achieved
                    } else { // Иначе инкрементируем
                        habits[habitIndex].goalCount = (habits[habitIndex].goalCount ?? 0) + 1
                    }
                } else { // Если отменяем выполнение, и не передан countAchieved
                    if countAchieved == nil && (habits[habitIndex].goalCount ?? 0) > 0 {
                         // Уменьшаем, если не было явного значения countAchieved
                        // habits[habitIndex].goalCount = (habits[habitIndex].goalCount ?? 1) - 1 // Опасно, может уйти в минус если было 0
                        // Лучше сбрасывать или обрабатывать декремент аккуратнее
                    } else if let achieved = countAchieved {
                        habits[habitIndex].goalCount = achieved // Если отменили, но передали новое значение
                    }
                }
            }
            // Не забываем сохранить изменения в привычках, если goalCount обновился
            saveHabits()
        }
        saveHabitLogs()
    }

    func isHabitCompletedOn(habitID: UUID, date: Date) -> Bool {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        guard let habit = habits.first(where: { $0.id == habitID }) else { return false }

        // Сначала проверяем лог
        let logExistsAndCompleted = habitLogs.contains {
            $0.habitID == habitID &&
            $0.isCompleted &&
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate)
        }
        if !logExistsAndCompleted { return false } // Если лога нет или он не isCompleted, то привычка не выполнена

        // Если это количественная цель, проверяем достигнут ли target
        if let currentCount = habit.goalCount, habit.goalTargetCount > 0 { // Убрал >1, чтобы работало и для target=1
            return currentCount >= habit.goalTargetCount
        }
        
        // Если это цель по времени, и loggedDuration есть в логе
        if let goalDuration = habit.goalDuration, goalDuration > 0 {
            if let log = habitLogs.first(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) }),
               let loggedDuration = log.loggedDuration {
                return loggedDuration >= goalDuration
            }
            return false // Если есть goalDuration, но нет loggedDuration в логе (или самого лога)
        }
        
        // Если нет количественной цели или цели по времени, но лог есть и isCompleted = true
        return true
    }
    
    // MARK: - Statistics
    var habitsForWidget: [Habit] {
        habits.filter { !$0.isArchived && $0.showOnWidget }
              .sorted { $0.creationDate < $1.creationDate } // Или другая логика сортировки для виджета
              .prefix(4)
              .map{$0}
    }

    func dailyCompletionPercentage() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let activeDueHabits = habits.filter { !$0.isArchived && isHabitDueOn(habit: $0, date: today) }
        
        guard !activeDueHabits.isEmpty else { return 0.0 }
        
        let completedTodayCount = activeDueHabits.filter { isHabitCompletedOn(habitID: $0.id, date: today) }.count
        return (Double(completedTodayCount) / Double(activeDueHabits.count)) * 100.0
    }

    func isHabitDueOn(habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        let weekdayOfDate = calendar.component(.weekday, from: date) // 1 (Вс) - 7 (Сб)
        
        switch habit.frequency {
        case .daily:
            return true
        case .specificDaysOfWeek(let dueDays):
            // dueDays должны хранить числа 1-7, где 1=Вс (стандарт Calendar)
            return dueDays.contains(weekdayOfDate)
        case .timesPerWeek:
            // Для "N раз в неделю" упрощенно считаем, что она "должна быть" каждый день,
            // а логика выполнения и отслеживания количества ложится на пользователя и статистику.
            // Либо нужна более сложная логика определения "должна ли она быть выполнена СЕГОДНЯ,
            // чтобы уложиться в N раз до конца недели". Пока оставляем true.
            return true
        case .everyXDays(let interval):
            guard interval > 0 else { return false }
            let startDate = calendar.startOfDay(for: habit.creationDate)
            let targetDate = calendar.startOfDay(for: date)
            
            // Привычка не может быть "должна" раньше даты ее создания
            guard targetDate >= startDate else { return false }
            
            if let daysPassed = calendar.dateComponents([.day], from: startDate, to: targetDate).day {
                return daysPassed % interval == 0
            }
            return false
        }
    }

    // MARK: - Persistence
    private func saveData<T: Codable>(_ data: T, key: String) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encodedData, forKey: key)
            // print("HabitDataStore: Данные сохранены по ключу \(key)")
        } catch {
            print("HabitDataStore: Ошибка кодирования и сохранения данных для ключа \(key): \(error.localizedDescription)")
        }
    }

    private func loadData<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            // print("HabitDataStore: Нет данных для ключа \(key)")
            return nil
        }
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            // print("HabitDataStore: Данные успешно загружены для ключа \(key)")
            return decodedData
        } catch {
            print("HabitDataStore: Ошибка декодирования данных для ключа \(key): \(error.localizedDescription)")
            UserDefaults.standard.removeObject(forKey: key) // Удаляем поврежденные данные
            print("HabitDataStore: Поврежденные данные для ключа \(key) были удалены.")
            return nil
        }
    }

    func saveHabits() { saveData(habits, key: habitsKey) }
    func loadHabits() {
        if let loaded: [Habit] = loadData(key: habitsKey) {
            self.habits = loaded
        } else {
            self.habits = [] // Если загрузка не удалась или данных нет, начинаем с пустого массива
        }
        // sortHabits() // Сортировка теперь вызывается в init после загрузки или setupSampleHabits
    }

    func saveHabitLogs() { saveData(habitLogs, key: habitLogsKey) }
    func loadHabitLogs() {
        if let loaded: [HabitLog] = loadData(key: habitLogsKey) {
            self.habitLogs = loaded
        } else {
            self.habitLogs = []
        }
    }
}

// Расширение для удобного создания мокового DataStore в SwiftUI Previews
extension HabitDataStore {
    static var preview: HabitDataStore = {
        let dataStore = HabitDataStore() // Он вызовет свой init и setupSampleHabits если нужно
        // Если нужно специфичное состояние для превью, можно дополнительно модифицировать dataStore здесь
        // Например, убедиться, что есть и активные, и архивные привычки для тестирования всех секций List.
        if !dataStore.habits.contains(where: \.isArchived) && !dataStore.habits.isEmpty {
            // Архивируем одну из привычек для превью, если все активны
            if let firstHabitId = dataStore.habits.first?.id,
               let habitToArchive = dataStore.habits.first(where: {$0.id == firstHabitId}) {
                dataStore.archiveHabit(habitToArchive, shouldArchive: true)
            }
        }
        return dataStore
    }()
}
