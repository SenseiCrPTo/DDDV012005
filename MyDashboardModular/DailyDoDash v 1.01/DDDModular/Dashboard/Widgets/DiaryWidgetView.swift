import SwiftUI

struct DiaryWidgetView: View {
    @EnvironmentObject var diaryDataStore: DiaryDataStore

    // Используем данные из diaryDataStore для отображения настроения
    private var currentMoodDisplay: (icon: String, name: String, color: Color) {
        let moodData = diaryDataStore.mainMoodDisplay // Это свойство уже есть в вашем DiaryDataStore
        return (
            icon: moodData.icon ?? "questionmark.circle", // Иконка по умолчанию, если нет
            name: moodData.name,
            color: moodData.color ?? .gray // Цвет по умолчанию, если нет
        )
    }

    var body: some View {
        NavigationLink(destination: DiaryMiniAppView()) {
            VStack(alignment: .leading, spacing: 6) {
                // Заголовок и иконка настроения
                HStack {
                    Text("Дневник")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: currentMoodDisplay.icon)
                        .foregroundColor(currentMoodDisplay.color)
                        .font(.title3) // Немного увеличим иконку
                }

                // Название настроения
                Text(currentMoodDisplay.name)
                    .font(.subheadline)
                    .foregroundColor(currentMoodDisplay.color)
                    .lineLimit(1)

                // Выдержка из последней записи
                Text(diaryDataStore.latestEntryExcerpt) // Используем свойство из DiaryDataStore
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3) // Позволим до 3 строк для выдержки
                    .frame(minHeight: 40, alignment: .top) // Дадим немного высоты для текста

                Spacer() // Чтобы текст напоминания был внизу

                // Текст напоминания
                Text(diaryDataStore.reminderText) // Используем свойство из DiaryDataStore
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading) // Убедитесь, что minHeight вам подходит
            .background(.thinMaterial) // Используем .thinMaterial вместо Material.thin для большей совместимости
            .cornerRadius(16)
            .foregroundColor(.primary) // Основной цвет текста по умолчанию
        }
        .buttonStyle(PlainButtonStyle()) // Чтобы убрать стандартный вид кнопки у NavigationLink в некоторых контекстах
    }
}

struct DiaryWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryWidgetView()
            .environmentObject(DiaryDataStore.preview) // Используем ваш статический экземпляр для превью
            .padding()
            .frame(width: 170, height: 180) // Задаем размеры для превью
            .background(Color(UIColor.systemGray5))
            .previewLayout(.sizeThatFits) // Альтернатива .fixed
    }
}
