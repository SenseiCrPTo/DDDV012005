// MyDashboardModular/Dashboard/Widgets/TasksWidgetView.swift
import SwiftUI

struct TasksWidgetView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore // ИСПОЛЬЗУЕМ @EnvironmentObject

    var body: some View {
        NavigationLink(destination: TasksMiniAppView()) { // TasksMiniAppView получит taskDataStore из окружения
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Задачи")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    // Image(systemName: "list.bullet.clipboard.fill") // Опционально
                }
                .padding(.bottom, 2) // Уменьшил отступ для компактности

                // Используем свойство monthlyTaskStatsForWidget
                let monthlyStats = taskDataStore.monthlyTaskStatsForWidget
                if monthlyStats.total > 0 {
                    HStack { // Для выравнивания текста и ProgressView
                        Text("Цели на месяц: \(monthlyStats.completed)/\(monthlyStats.total)")
                            .font(.caption)
                        Spacer() // Чтобы ProgressView не растягивался на всю ширину, если текст короткий
                    }
                    ProgressView(value: Double(monthlyStats.completed), total: Double(monthlyStats.total))
                        .progressViewStyle(LinearProgressViewStyle(tint: (monthlyStats.completed == monthlyStats.total && monthlyStats.total > 0) ? .green : .orange))
                        .padding(.bottom, 4)
                } else {
                    Text("Нет целей на этот месяц.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }

                // Используем свойство topMonthlyGoalsForWidget
                let topGoals = taskDataStore.topMonthlyGoalsForWidget
                if !topGoals.isEmpty {
                    Text("Основные цели на месяц:")
                        .font(.caption.bold())
                    // Показываем только одну, как на скриншоте пользователя "Снимок экрана 2025-05-07 в 5.51.06 PM.jpg"
                    // Если нужно больше, измените .prefix(1) на .prefix(3) или уберите prefix
                    ForEach(topGoals.prefix(1)) { task in
                        TaskWidgetRow(task: task) // TaskWidgetRow будет определен ниже
                    }
                }
                
                // Используем свойство tasksDueTodayForWidget
                let todayTasks = taskDataStore.tasksDueTodayForWidget
                if !todayTasks.isEmpty {
                    Text("Текущие задачи на сегодня:")
                        .font(.caption.bold())
                        .padding(.top, topGoals.isEmpty ? 0 : 4) // Отступ, если есть цели выше
                    ForEach(todayTasks.prefix(2)) { task in
                        TaskWidgetRow(task: task) // TaskWidgetRow будет определен ниже
                    }
                }
                
                if topGoals.isEmpty && todayTasks.isEmpty && monthlyStats.total == 0 {
                     Text("Нет активных задач или целей!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading) // Адаптируйте высоту
            .background(Material.thin)
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Вспомогательное View для отображения строки задачи в виджете
// ОПРЕДЕЛЯЕМ TaskWidgetRow ЗДЕСЬ (или в отдельном файле и импортируем)
struct TaskWidgetRow: View {
    let task: Task // Получаем задачу как константу, если не меняем ее здесь

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : (task.isImportant ? .orange : .secondary))
            Text(task.title)
                .font(.caption)
                .foregroundColor(task.isCompleted ? .gray : .primary)
                .strikethrough(task.isCompleted, color: .gray)
                .lineLimit(1)
            Spacer()
            if task.isImportant && !task.isCompleted {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption2)
            }
        }
    }
}

struct TasksWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TasksWidgetView()
                // ИСПРАВЛЕНО: Используем TaskDataStore.previewWithWidgetData()
                .environmentObject(TaskDataStore.previewWithWidgetData())
                .padding()
                .frame(width: 200, height: 220) // Адаптируйте размер для превью
        }
    }
}
