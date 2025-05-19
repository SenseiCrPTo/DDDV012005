import SwiftUI

struct DiaryEntryRowView: View {
    let entry: DiaryEntry             // Модель записи из Models/DiaryEntry.swift
    let moodSettings: [MoodSetting]   // Массив всех настроек настроений из DataStore

    // Находит MoodSetting, соответствующий moodID в записи
    private var currentMoodSetting: MoodSetting? {
        guard let moodID = entry.moodID else { return nil }
        return moodSettings.first { $0.id == moodID }
    }
    
    // Форматтер для дня (например, "12")
    private static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    // Форматтер для месяца (например, "мая")
    private static var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Сокращенное название месяца
        formatter.locale = Locale(identifier: "ru_RU") // Русская локализация
        return formatter
    }()

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Блок с датой
            VStack(alignment: .center) {
                Text(entry.date, formatter: Self.dayFormatter)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(Color.accentColor) // Используем accentColor темы
                Text(entry.date, formatter: Self.monthFormatter)
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, height: 50)
            .background(Color(UIColor.systemGray6)) // Нейтральный фон
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Основное содержимое строки
            VStack(alignment: .leading, spacing: 4) { // Уменьшил spacing
                Text(entry.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if !entry.text.isEmpty &&
                   (entry.displayTitle.isEmpty ||
                    entry.displayTitle.prefix(50).lowercased() != entry.text.prefix(50).lowercased()) {
                     Text(entry.text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(entry.displayTitle.isEmpty ? 3 : 2) // Больше строк, если нет заголовка
                        .truncationMode(.tail)
                }
                
                // Отображение выбранного настроения и его оценки
                if let mood = currentMoodSetting {
                    HStack(spacing: 5) {
                        if let iconName = mood.iconName, !iconName.isEmpty {
                            Image(systemName: iconName)
                                .foregroundColor(mood.color ?? .secondary) // Цвет иконки из MoodSetting
                                .font(.callout)
                        } else if let color = mood.color {
                            Circle().fill(color).frame(width: 10, height: 10)
                        }
                        Text(mood.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Отображаем числовую оценку ratingValue
                        Text("[\(mood.ratingValue > 0 ? "+" : "")\(mood.ratingValue)]")
                            .font(.caption)
                            .bold()
                            .foregroundColor(mood.ratingValue > 3 ? .green : (mood.ratingValue < -3 ? .red : .orange)) // Цветовое кодирование оценки
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer() // Прижимает контент влево
            
            if entry.isBookmarked {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.orange)
                    .font(.callout)
            }
        }
        .padding(.vertical, 8) // Вертикальные отступы для всей строки
    }
}

struct DiaryEntryRowView_Previews: PreviewProvider {
    // Для превью нужны моковые данные
    static let sampleMoodSettingsForPreview = [
        MoodSetting(name: "Счастье", iconName: "face.smiling.fill", colorHex: "FFD700", ratingValue: 8), // Gold
        MoodSetting(name: "Спокойствие", iconName: "wind", colorHex: "ADD8E6", ratingValue: 2),        // LightBlue
        MoodSetting(name: "Печаль", iconName: "face.sad", colorHex: "6495ED", ratingValue: -5)          // CornflowerBlue
    ]
    static let sampleEntriesForPreview = [
        DiaryEntry(date: Date(), title: "Прекрасный день", text: "Много гулял и наслаждался погодой. Чувствую себя отлично!", moodID: sampleMoodSettingsForPreview[0].id, isBookmarked: true),
        DiaryEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, title: "Рабочие будни", text: "Обычный день в офисе, ничего особенного.", moodID: sampleMoodSettingsForPreview[1].id),
        DiaryEntry(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, text: "Немного загрустил вечером, но потом посмотрел хороший фильм и все наладилось. Завтра будет новый день.", moodID: sampleMoodSettingsForPreview[2].id, isBookmarked: false),
        DiaryEntry(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, title: "Просто заметка", text: "Нужно не забыть купить молоко.", moodID: nil)
    ]

    static var previews: some View {
        List {
            ForEach(sampleEntriesForPreview) { entry in
                DiaryEntryRowView(entry: entry, moodSettings: sampleMoodSettingsForPreview)
            }
        }
        .previewLayout(.sizeThatFits) // Для удобного просмотра отдельной строки
    }
}
