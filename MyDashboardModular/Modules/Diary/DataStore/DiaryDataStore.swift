import SwiftUI
import Combine // Добавил, так как ObservableObject часто используется с Combine

// Предполагается, что DiaryEntry, MoodSetting, ChartTimePeriod
// определены в соответствующих файлах Models.
// Например:
// Modules/Diary/Models/DiaryEntry.swift
// Modules/Diary/Models/MoodSetting.swift
// Shared/Models/ChartTimePeriod.swift (если это ChartTimePeriod, а не тот, что внутри класса)

// Если ChartTimePeriod определен внутри класса, то он там и останется.
// Я вынес его наружу для примера, если он используется где-то еще.
// enum ChartTimePeriod: String, CaseIterable, Identifiable { ... }

class DiaryDataStore: ObservableObject {
    // Enum для выбора периода на графике статистики (если он используется только здесь, можно оставить внутри)
    // Если он используется в других местах, лучше вынести его из класса.
    enum ChartTimePeriodLocal: String, CaseIterable, Identifiable { // Переименовал, чтобы не конфликтовать, если есть глобальный
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
        case allTime = "Всё время"
        var id: String { self.rawValue }
    }
    
    @Published var entries: [DiaryEntry] = []
    @Published var moodSettings: [MoodSetting] = []

    // Ключи для UserDefaults - остаются без изменений
    private let entriesKey = "diaryEntries_v3_moodID_only"
    private let moodSettingsKey = "moodSettings_v3_with_ratingValue"

    init() {
        print("DiaryDataStore: Инициализация...")
        loadMoodSettings() // Сначала загружаем настройки настроений
        loadEntries()      // Затем загружаем записи, которые могут на них ссылаться
        
        // Настройка стандартных данных, если они отсутствуют
        if moodSettings.isEmpty && UserDefaults.standard.data(forKey: moodSettingsKey) == nil {
            print("DiaryDataStore: Настройки настроений не загружены или пусты. Установка стандартных.")
            setupDefaultMoodSettings() // Этот метод уже вызывает saveMoodSettings()
        } else if !moodSettings.isEmpty { // Если загружены, просто отсортируем
            sortMoodSettings()
        }
        
        if entries.isEmpty && UserDefaults.standard.data(forKey: entriesKey) == nil && !moodSettings.isEmpty {
            print("DiaryDataStore: Записи не загружены или пусты. Создание примера записи.")
            setupSampleEntry() // Этот метод уже вызывает saveEntries()
        } else if !entries.isEmpty { // Если загружены, просто отсортируем
            sortEntries()
        }
        print("DiaryDataStore: Инициализация завершена. Записей: \(entries.count), Настроений: \(moodSettings.count).")
    }

    // MARK: - MoodSetting Management (Твой код с мелкими правками)
    func addMoodSetting(name: String, iconName: String?, colorHex: String?, ratingValue: Int) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { print("DiaryDataStore Error: Mood name cannot be empty."); return }
        guard !moodSettings.contains(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) else {
            print("DiaryDataStore Error: Mood with name '\(trimmedName)' already exists."); return
        }
        
        let newMood = MoodSetting(name: trimmedName, iconName: iconName, colorHex: colorHex, isDefault: false, ratingValue: ratingValue)
        moodSettings.append(newMood)
        sortMoodSettings()
        saveMoodSettings()
    }

    func updateMoodSetting(_ moodToUpdate: MoodSetting) {
        guard let index = moodSettings.firstIndex(where: { $0.id == moodToUpdate.id }) else { return }
        moodSettings[index] = moodToUpdate
        sortMoodSettings()
        saveMoodSettings()
    }

    func deleteMoodSetting(id: UUID) {
        var entriesModified = false
        // Обновляем записи, где использовалось это настроение
        for i in entries.indices {
            if entries[i].moodID == id {
                entries[i].moodID = nil
                entriesModified = true
            }
        }
        if entriesModified { saveEntries() }
        
        moodSettings.removeAll { $0.id == id }
        // sortMoodSettings() // Не обязательно, если удаление не меняет порядок остальных
        saveMoodSettings()
    }

    private func sortMoodSettings() {
        moodSettings.sort {
            if $0.isDefault && !$1.isDefault { return true }
            if !$0.isDefault && $1.isDefault { return false }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private func setupDefaultMoodSettings() {
        moodSettings = [
            MoodSetting(name: "Отличное", iconName: "face.smiling.fill", colorHex: "34C759", isDefault: true, ratingValue: 8),
            MoodSetting(name: "Хорошее", iconName: "face.smiling", colorHex: "FFCC00", isDefault: true, ratingValue: 5),
            MoodSetting(name: "Нормальное", iconName: "face.dashed", colorHex: "FF9500", isDefault: true, ratingValue: 0),
            MoodSetting(name: "Так себе", iconName: "face.rolling.eyes", colorHex: "8E8E93", isDefault: true, ratingValue: -3),
            MoodSetting(name: "Плохое", iconName: "bolt.heart.fill", colorHex: "007AFF", isDefault: true, ratingValue: -6), // Иконка и цвет немного странные для "плохого"
            MoodSetting(name: "Ужасное", iconName: "face.dizzy.fill", colorHex: "FF3B30", isDefault: true, ratingValue: -9)
        ]
        sortMoodSettings()
        saveMoodSettings()
    }

    // MARK: - DiaryEntry Management (Твой код)
    func addEntry(date: Date, title: String?, text: String, moodID: UUID?, isBookmarked: Bool = false) {
        let newEntry = DiaryEntry(date: date, creationTimestamp: Date(), lastModifiedTimestamp: Date(), title: title, text: text, moodID: moodID, isBookmarked: isBookmarked)
        entries.append(newEntry)
        sortEntries()
        saveEntries()
    }
    func updateEntry(_ entry: DiaryEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        var mutableEntry = entry
        mutableEntry.lastModifiedTimestamp = Date() // Обновляем время последнего изменения
        entries[index] = mutableEntry
        sortEntries()
        saveEntries()
    }
    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        saveEntries() // Не забываем сохранить после удаления
    }
    
    private func sortEntries() {
        entries.sort {
            // Сначала по дате (более новые вверху)
            if Calendar.current.isDate($0.date, inSameDayAs: $1.date) {
                // Если даты одинаковые, то по времени создания (более новые вверху)
                return $0.creationTimestamp > $1.creationTimestamp
            }
            return $0.date > $1.date
        }
    }
    
    private func setupSampleEntry() {
        guard !moodSettings.isEmpty else {
            print("DiaryDataStore: Не могу создать пример записи, нет настроек настроений.")
            return
        }
        let calendar = Calendar.current
        let today = Date()
        let sampleEntriesData: [(dateOffset: Int, title: String, text: String, moodNameToFind: String?)] = [
            (0, "Продуктивный день", "Много всего успел, настроение отличное!", "Отличное"),
            (-1, "Спокойный вечер", "Читал книгу, смотрел фильм.", "Хорошее"),
            (-2, "Рабочая встреча", "Обсудили важные вопросы.", "Нормальное"),
        ]
        var tempEntriesToAdd: [DiaryEntry] = []
        for sampleItem in sampleEntriesData {
            if let date = calendar.date(byAdding: .day, value: sampleItem.dateOffset, to: today) {
                var moodIDForEntry: UUID? = nil
                if let moodNameToFind = sampleItem.moodNameToFind {
                    moodIDForEntry = moodSettings.first(where: { $0.name.caseInsensitiveCompare(moodNameToFind) == .orderedSame })?.id
                }
                // Добавляем только если такой записи (по дате и заголовку) еще нет
                if !entries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) && $0.displayTitle == sampleItem.title }) {
                    tempEntriesToAdd.append(DiaryEntry(date: date, title: sampleItem.title, text: sampleItem.text, moodID: moodIDForEntry))
                }
            }
        }
        if !tempEntriesToAdd.isEmpty {
            entries.append(contentsOf: tempEntriesToAdd)
            sortEntries()
            saveEntries()
        }
    }

    // MARK: - Persistence (Твой код)
    private func saveData<T: Codable>(_ data: T, key: String) {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(data), forKey: key)
        } catch {
            print("DiaryDataStore: Ошибка кодирования \(key): \(error.localizedDescription)")
        }
    }
    private func loadData<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("DiaryDataStore: Ошибка декодирования \(key): \(error.localizedDescription). Данные будут удалены.")
            UserDefaults.standard.removeObject(forKey: key) // Удаляем поврежденные данные
            return nil
        }
    }
    func saveEntries() { saveData(entries, key: entriesKey) }
    func loadEntries() {
        if let loaded: [DiaryEntry] = loadData(key: entriesKey) { self.entries = loaded } else { self.entries = [] }
        sortEntries() // Сортируем после загрузки
    }
    func saveMoodSettings() { saveData(moodSettings, key: moodSettingsKey) }
    func loadMoodSettings() {
        if let loaded: [MoodSetting] = loadData(key: moodSettingsKey) { self.moodSettings = loaded } else { self.moodSettings = [] }
        sortMoodSettings() // Сортируем после загрузки
    }
    
    // MARK: - Computed Properties for UI / Widget (Твой код)
    var daysJournaledCount: Int { Set(entries.map { Calendar.current.startOfDay(for: $0.date) }).count }
    var entriesCountString: String { "\(entries.count)" } // Это свойство не используется в виджете, но оставляем
    var wordCount: Int { entries.reduce(0) { $0 + $1.text.split { $0.isWhitespace }.count } } // И это

    var mainMoodDisplay: (name: String, icon: String?, color: Color?) {
        // Ищем последнюю запись с настроением за сегодня или вчера
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let sortedEntriesWithMood = entries.filter { $0.moodID != nil }
                                          .sorted { $0.date > $1.date } // Сначала самые новые

        if let entryForToday = sortedEntriesWithMood.first(where: { calendar.isDate($0.date, inSameDayAs: today) && $0.moodID != nil }),
           let moodID = entryForToday.moodID, let setting = moodSettings.first(where: { $0.id == moodID }) {
            return (setting.name, setting.iconName, setting.color)
        } else if let entryForYesterday = sortedEntriesWithMood.first(where: { calendar.isDate($0.date, inSameDayAs: yesterday) && $0.moodID != nil }),
                  let moodID = entryForYesterday.moodID, let setting = moodSettings.first(where: { $0.id == moodID }) {
            return (setting.name, setting.iconName, setting.color)
        } else if let latestEntryWithMood = sortedEntriesWithMood.first, // Любая последняя запись с настроением
                  let moodID = latestEntryWithMood.moodID, let setting = moodSettings.first(where: { $0.id == moodID }) {
            return (setting.name, setting.iconName, setting.color)
        }
        return ("Не указано", "questionmark.circle", .gray)
    }

    var reminderText: String {
        if let entry = entries.first { // entries уже отсортированы, первая - самая новая
            if Calendar.current.isDateInToday(entry.date) {
                return "Отлично! Запись сегодня уже есть."
            } else if Calendar.current.isDateInYesterday(entry.date) {
                return "Вчера была запись. Сегодня?"
            }
        }
        return "Время для новой записи!"
    }

    var latestEntryExcerpt: String {
        if let firstEntry = entries.first { // entries уже отсортированы
            let title = firstEntry.displayTitle // displayTitle должен быть в DiaryEntry
            if !title.isEmpty {
                return String(title.prefix(50)) // Ограничение длины для виджета
            } else if !firstEntry.text.isEmpty {
                return String(firstEntry.text.prefix(50)) + (firstEntry.text.count > 50 ? "..." : "")
            }
        }
        return "Начни писать сегодня..." // Это будет показано, если нет записей
    }
    
    var datesWithEntries: Set<DateComponents> { Set(entries.map { Calendar.current.dateComponents([.year, .month, .day], from: $0.date) }) }
    
    var moodFrequency: [(moodSetting: MoodSetting, count: Int)] {
        var freq = [UUID: Int]()
        entries.forEach { entry in
            if let id = entry.moodID { freq[id, default: 0] += 1 }
        }
        return freq.compactMap { id, count in
            moodSettings.first { $0.id == id }.map { ($0, count) }
        }.sorted {
            if $0.1 != $1.1 { return $0.1 > $1.1 } // Сначала по количеству (убывание)
            return $0.0.name.localizedCaseInsensitiveCompare($1.0.name) == .orderedAscending // Затем по имени
        }
    }
    
    var journalStreaks: (current: Int, longest: Int) {
        guard !entries.isEmpty else { return (0,0) }
        let calendar = Calendar.current
        // Получаем уникальные дни с записями, отсортированные по возрастанию
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !uniqueDays.isEmpty else { return (0,0) }

        var longestStreak = 0
        var currentStreak = 0

        if uniqueDays.count == 1 {
            longestStreak = 1
        } else {
            for i in 0..<uniqueDays.count {
                if i == 0 {
                    currentStreak = 1
                } else {
                    // Проверяем, является ли текущий день следующим за предыдущим
                    if let expectedPreviousDay = calendar.date(byAdding: .day, value: -1, to: uniqueDays[i]),
                       expectedPreviousDay == uniqueDays[i-1] {
                        currentStreak += 1
                    } else {
                        // Серия прервалась
                        longestStreak = max(longestStreak, currentStreak)
                        currentStreak = 1 // Начинаем новую серию с текущего дня
                    }
                }
                longestStreak = max(longestStreak, currentStreak) // Обновляем максимальную серию в конце каждой итерации
            }
        }
        
        // Расчет текущей непрерывной серии до сегодняшнего или вчерашнего дня
        var currentContinuosStreak = 0
        let todayStart = calendar.startOfDay(for: Date())
        
        if uniqueDays.contains(todayStart) { // Если сегодня есть запись
            var dayToCheck = todayStart
            while uniqueDays.contains(dayToCheck) {
                currentContinuosStreak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayToCheck) else { break }
                dayToCheck = previousDay
            }
        } else { // Если сегодня нет записи, проверяем вчерашний день для определения конца текущей серии
            let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
            if uniqueDays.contains(yesterdayStart) {
                var dayToCheck = yesterdayStart
                while uniqueDays.contains(dayToCheck) {
                    currentContinuosStreak += 1
                    guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dayToCheck) else { break }
                    dayToCheck = previousDay
                }
            }
        }
        // Если самая первая запись - единственная, longestStreak должен быть 1
        if longestStreak == 0 && !uniqueDays.isEmpty { longestStreak = 1}
        
        return (currentContinuosStreak, longestStreak)
    }

    struct MoodChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let rating: Int // Используем ratingValue из MoodSetting
    }

    // Передаем локальный enum ChartTimePeriodLocal
    func dailyMoodRatings(forPeriod period: ChartTimePeriodLocal) -> [MoodChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        var startDate: Date
        
        let endOfToday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: today)!) // Начало завтрашнего дня

        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today))! // Последние 7 дней включая сегодня
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: calendar.startOfDay(for: today))! // Последний месяц
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: calendar.startOfDay(for: today))! // Последний год
        case .allTime:
            startDate = entries.min { $0.date < $1.date }?.date ?? calendar.startOfDay(for: today)
        }
        startDate = calendar.startOfDay(for: startDate) // Убедимся, что это начало дня

        let periodEntries = entries.filter { $0.date >= startDate && $0.date < endOfToday && $0.moodID != nil }
        guard !periodEntries.isEmpty else { return [] }

        // Группируем записи по дню, берем последнюю запись за день, если их несколько
        let groupedByDay = Dictionary(grouping: periodEntries) { calendar.startOfDay(for: $0.date) }
        
        var chartData: [MoodChartDataPoint] = []
        for (day, entriesOnDay) in groupedByDay {
            // Берем последнюю запись за день (по creationTimestamp)
            if let latestEntry = entriesOnDay.max(by: { $0.creationTimestamp < $1.creationTimestamp }),
               let moodID = latestEntry.moodID,
               let moodSetting = moodSettings.first(where: { $0.id == moodID }) {
                chartData.append(MoodChartDataPoint(date: day, rating: moodSetting.ratingValue))
            }
        }
        return chartData.sorted { $0.date < $1.date } // Сортируем по дате для графика
    }
    
    // MARK: - Static Preview Instance
    static var preview: DiaryDataStore = {
        let dataStore = DiaryDataStore() // Вызовет init()
        // init() уже вызывает setupDefaultMoodSettings() и setupSampleEntry() если нужно.
        // Дополнительная настройка для превью обычно не требуется, если init() корректно заполняет данные.
        
        // Можно добавить явную запись для сегодняшнего дня, если setupSampleEntry не гарантирует это
        let today = Calendar.current.startOfDay(for: Date())
        if !dataStore.entries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            if let mood = dataStore.moodSettings.first(where: { $0.name == "Хорошее"}) {
                dataStore.addEntry(date: Date(), title: "Запись для превью", text: "Текущий день.", moodID: mood.id)
            }
        }
        print("DiaryDataStore.preview: Entries count: \(dataStore.entries.count), MoodSettings: \(dataStore.moodSettings.count)")
        return dataStore
    }()
} // Конец класса DiaryDataStore


// Убедись, что DiaryEntry и MoodSetting определены и являются Codable & Identifiable.
// Например:
/*
struct DiaryEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date // Дата, к которой относится запись
    var creationTimestamp: Date // Когда была создана
    var lastModifiedTimestamp: Date // Когда была последний раз изменена
    var title: String?
    var text: String
    var moodID: UUID? // Ссылка на MoodSetting
    var isBookmarked: Bool = false

    var displayTitle: String { // Для latestEntryExcerpt
        title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

struct MoodSetting: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var iconName: String?
    var colorHex: String? // Хранится как HEX строка
    var isDefault: Bool = false // Стандартное настроение, которое нельзя удалить
    var ratingValue: Int // Например, от -10 до +10 для графиков

    var color: Color? { // Вычисляемое свойство для получения SwiftUI Color
        guard let hex = colorHex else { return nil }
        return Color(hex: hex)
    }
}
*/
