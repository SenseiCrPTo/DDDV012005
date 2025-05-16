import SwiftUI

// Вспомогательный View для отображения одной привычки в сетке виджета
struct HabitWidgetItemView: View {
    @EnvironmentObject var habitDataStore: HabitDataStore // Получаем из окружения
    let habit: Habit // Привычка передается как параметр

    private var isCompletedToday: Bool {
        habitDataStore.isHabitCompletedOn(habitID: habit.id, date: Date())
    }

    private var isDueToday: Bool {
        habitDataStore.isHabitDueOn(habit: habit, date: Date())
    }

    var body: some View {
        Button(action: {
            if isDueToday && !habit.isArchived {
                // Создаем инвертированное значение для isCompleted
                let newCompletionStatus = !isCompletedToday
                habitDataStore.logHabitCompletion(habitID: habit.id, date: Date(), isCompleted: newCompletionStatus)
                
                // Если это количественная цель, и мы ее "выполнили" (достигли target),
                // а теперь "отменяем", нужно корректно обновить goalCount.
                // Логика в logHabitCompletion должна это учитывать.
            }
        }) {
            VStack(alignment: .center, spacing: 6) {
                Image(systemName: habit.iconName)
                    .font(.title3)
                    .foregroundColor(isCompletedToday && isDueToday ? .white : habit.color)
                    .frame(width: 36, height: 36)
                    .background(isCompletedToday && isDueToday ? habit.color : habit.color.opacity(0.2))
                    .clipShape(Circle())
            
                Text(habit.name)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .frame(height: 30) // Для выравнивания
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 8)
            .opacity(isDueToday && !habit.isArchived ? 1.0 : (habit.isArchived ? 0.4 : 0.6)) // Приглушаем архивные и не "due"
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isDueToday || habit.isArchived) // Кнопка неактивна, если не "due" или архивирована
    }
}


struct HabitWidgetView: View {
    @EnvironmentObject var habitDataStore: HabitDataStore // Получаем из окружения

    // Колонки для сетки привычек
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
        // Можно добавить больше колонок, если нужно, например, для более крупных виджетов
        // GridItem(.flexible(), spacing: 10),
        // GridItem(.flexible(), spacing: 10)
    ]
    
    // Определяем, какие привычки показывать. Берем только первые 4.
    private var habitsToDisplay: [Habit] {
        Array(habitDataStore.habitsForWidget.prefix(4))
    }

    var body: some View {
        // NavigationLink для перехода к полному списку привычек
        NavigationLink(destination: HabitsMiniAppView()) { // HabitsMiniAppView тоже будет использовать @EnvironmentObject
            VStack(alignment: .leading, spacing: 12) {
                Text("Привычки")
                    .font(.headline)
                    .padding(.bottom, 4)
                    .foregroundColor(.primary)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Всего активных:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(habitDataStore.habits.filter { !$0.isArchived }.count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Выполнено сегодня:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f%%", habitDataStore.dailyCompletionPercentage()))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(completionColor(habitDataStore.dailyCompletionPercentage()))
                    }
                }
                .padding(.bottom, 8)

                if habitsToDisplay.isEmpty {
                    Text("Нет привычек для отображения на виджете. Отметьте их в настройках привычек.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 60) // Занимаем место
                        .padding(.vertical)
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(habitsToDisplay) { habit in // habitsToDisplay уже содержит до 4 элементов
                            HabitWidgetItemView(habit: habit) // habitDataStore передастся из окружения
                        }
                    }
                    // Добавляем Spacer, если привычек меньше 3, чтобы виджет не "прыгал" по высоте
                    if habitsToDisplay.count > 0 && habitsToDisplay.count < 3 {
                         Spacer().frame(minHeight: 40) // Высота одного ряда HabitWidgetItemView + spacing
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading) // Минимальная высота виджета
            .background(.thinMaterial) // или .background(Material.regular)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle()) // Убирает стандартный стиль кнопки для NavigationLink
    }
    
    private func completionColor(_ percentage: Double) -> Color {
        if percentage >= 75 { return .green }
        if percentage >= 40 { return .orange } // Используем .orange вместо .yellow для лучшей читаемости
        return .red
    }
}

struct HabitWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        // Используем моковый dataStore из расширения HabitDataStore
        HabitWidgetView()
            .environmentObject(HabitDataStore.preview)
            .padding()
            .previewLayout(.sizeThatFits) // или .fixed(width: 300, height: 200)
            .background(Color.gray.opacity(0.1)) // Для контраста в превью
    }
}
