import SwiftUI

struct HabitRowView: View {
    @EnvironmentObject var habitDataStore: HabitDataStore // Получаем из окружения
    let habit: Habit // Привычка передается как параметр

    // Вычисляемые свойства для состояний (остаются без изменений)
    private var isCompletedToday: Bool {
        habitDataStore.isHabitCompletedOn(habitID: habit.id, date: Date())
    }
    private var isDueToday: Bool {
        habitDataStore.isHabitDueOn(habit: habit, date: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.iconName)
                .font(.title2)
                .foregroundColor(habit.color)
                .frame(width: 30, height: 30) // Можно сделать немного побольше, если нужно
                .background(habit.color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.headline)
                    .strikethrough(isCompletedToday && isDueToday && !habit.isArchived, color: .secondary) // Зачеркиваем только если не в архиве
                    .opacity(habit.isArchived ? 0.5 : 1.0)
                Text(habit.frequency.displayName) // Используем displayName из HabitFrequency
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(habit.isArchived ? 0.5 : 1.0)
            }
            Spacer()

            if !habit.isArchived && isDueToday {
                Button {
                    // Логика отметки выполнения
                    let newCompletionStatus = !isCompletedToday
                    habitDataStore.logHabitCompletion(habitID: habit.id, date: Date(), isCompleted: newCompletionStatus)
                } label: {
                    Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title2) // Можно сделать побольше для удобства нажатия
                        .foregroundColor(isCompletedToday ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle()) // Убирает стандартное оформление кнопки
            } else if habit.isArchived {
                Text("Архив")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(4)
            }
            // Если не isDueToday и не архивирована, кнопка просто не отображается
        }
        .padding(.vertical, 8)
        // Управляем прозрачностью всей строки в зависимости от состояния
        .opacity(isDueToday || habit.isArchived ? 1.0 : 0.6) // Менее прозрачно для неактуальных, но не архивных
    }
}

// Previews для HabitRowView
struct HabitRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Получаем моковый DataStore
        let dataStore = HabitDataStore.preview
        
        // Находим или создаем примеры привычек для превью
        let sampleHabitActive = dataStore.habits.first(where: { !$0.isArchived })
                                ?? Habit(name: "Пример Активная", iconName: "star.fill", colorHex: "007AFF")
        
        let sampleHabitCompleted = dataStore.habits.first(where: { !$0.isArchived && dataStore.isHabitCompletedOn(habitID: $0.id, date: Date()) })
                                   ?? Habit(name: "Пример Выполненная", iconName: "checkmark.seal.fill", colorHex: "34C759", frequency: .daily)
        // Для "выполненной" нужно также залогировать ее выполнение в dataStore.preview, если он еще не содержит такую
        if let habitToComplete = dataStore.habits.first(where: { $0.name == "Пример Выполненная" }) {
             if !dataStore.isHabitCompletedOn(habitID: habitToComplete.id, date: Date()) {
                dataStore.logHabitCompletion(habitID: habitToComplete.id, date: Date(), isCompleted: true)
             }
        } else if !dataStore.habits.contains(where: {$0.name == "Пример Выполненная"}) {
            let newCompletedHabit = Habit(name: "Пример Выполненная", iconName: "checkmark.seal.fill", colorHex: "34C759", frequency: .daily)
            dataStore.habits.append(newCompletedHabit) // Добавляем напрямую для превью
            dataStore.logHabitCompletion(habitID: newCompletedHabit.id, date: Date(), isCompleted: true)
        }


        let sampleHabitArchived = dataStore.habits.first(where: \.isArchived)
                                  ?? Habit(name: "Пример Архивная", iconName: "archivebox.fill", colorHex: "8E8E93", isArchived: true)
        
        let sampleHabitNotDue = Habit(name: "Пример Не Сегодня", iconName: "calendar.badge.exclamationmark", colorHex: "FF9500", frequency: .specificDaysOfWeek(days: [(Calendar.current.component(.weekday, from: Date()) % 7) + 2])) // Точно не сегодня


        return Group {
            HabitRowView(habit: sampleHabitActive)
                .previewDisplayName("Активная, не выполнена")

            HabitRowView(habit: sampleHabitCompleted)
                 .previewDisplayName("Активная, выполнена")
            
            HabitRowView(habit: sampleHabitNotDue)
                .previewDisplayName("Не актуальна сегодня")

            HabitRowView(habit: sampleHabitArchived)
                .previewDisplayName("Архивная")
        }
        .environmentObject(dataStore) // Передаем DataStore в окружение для всех превью в группе
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
    }
}
