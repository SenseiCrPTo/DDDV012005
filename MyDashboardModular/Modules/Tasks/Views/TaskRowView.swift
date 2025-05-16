// MyDashboardModular/Modules/Tasks/Views/TaskRowView.swift
import SwiftUI

struct TaskRowView: View {
    @EnvironmentObject var taskDataStore: TaskDataStore // Должен получать из окружения
    @Binding var task: Task

    // Форматирование даты
    private func formatDueDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")

        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm" // Время для сегодняшних задач
            return "Сегодня, \(formatter.string(from: date))"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Завтра"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Вчера"
        } else {
            if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
                formatter.dateFormat = "dd MMM" // "20 мая"
            } else {
                formatter.dateFormat = "dd MMM yy" // "20 мая 23"
            }
            return formatter.string(from: date)
        }
    }

    // Получение имени проекта
    private func getProjectName(id: UUID?) -> String? {
        guard let projectID = id else { return nil }
        return taskDataStore.projects.first(where: { $0.id == projectID })?.name
    }
    
    // Получение цвета проекта
    private func getProjectColor(id: UUID?) -> Color? {
        guard let projectID = id,
              let project = taskDataStore.projects.first(where: { $0.id == projectID }),
              let colorHex = project.colorHex else { return nil }
        return Color(hex: colorHex)
    }


    var body: some View {
        HStack(spacing: 12) { // Немного увеличил spacing
            // Цветная полоска от проекта или задачи
            if let taskColorHex = task.colorHex, let color = Color(hex: taskColorHex) {
                Rectangle().fill(color).frame(width: 5, height: 44).cornerRadius(2.5) // Сделал повыше
            } else if let projectID = task.projectID,
                      let projectColor = getProjectColor(id: projectID) {
                Rectangle().fill(projectColor).frame(width: 5, height: 44).cornerRadius(2.5)
            }


            VStack(alignment: .leading, spacing: 4) { // Уменьшил spacing для текста
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .lineLimit(2) // Позволим до двух строк для заголовка

                // Вспомогательная информация (дата, проект, важность, приоритет)
                HStack(spacing: 8) {
                    if task.isImportant && !task.isCompleted { // Звездочку только для активных важных
                        Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                    }
                    
                    let dueDateString = formatDueDate(task.dueDate)
                    if !dueDateString.isEmpty {
                        Label(dueDateString, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(task.isOverdue && !task.isCompleted ? .red : .secondary)
                    }
                    
                    if let projectID = task.projectID,
                       let projectName = getProjectName(id: projectID),
                       projectName != TaskProject.inbox.name { // Не показываем "Входящие"
                        Label(projectName, systemImage: "folder")
                            .font(.caption)
                            .foregroundColor(getProjectColor(id: projectID) ?? .blue) // Цвет проекта
                    }
                    
                    if task.priority > 0 && !task.isCompleted { // Приоритет только для активных
                        let priorityColor: Color = task.priority >= 3 ? .red : .orange
                        Text(String(repeating: "!", count: min(task.priority, 3))) // Максимум 3 восклицательных знака
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundColor(priorityColor)
                    }
                }
                .lineLimit(1)
            }
            Spacer() // Чтобы кнопка выполнения была справа
            
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .resizable().frame(width: 24, height: 24) // Чуть больше кнопка
                .foregroundColor(task.isCompleted ? .green : (task.isImportant ? .orange : .gray))
                .onTapGesture {
                    taskDataStore.toggleTaskCompletion(task: task)
                }
        }
        .padding(.vertical, 6) // Небольшой вертикальный отступ для строки
    }
}

// Preview для TaskRowView
struct TaskRowView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var task: Task
        var body: some View { TaskRowView(task: $task) }
    }
    static var previews: some View {
        let dataStore = TaskDataStore.preview
        let sampleTask1 = dataStore.tasks.first ?? Task(title: "Пример важной задачи для превью (просрочено)", dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, projectID: TaskProject.inbox.id, priority: 1, isImportant: true)
        let sampleTask2 = Task(title: "Пример выполненной задачи с длинным названием которое может не поместиться в одну строку", isCompleted: true, dueDate: Date(), projectID: dataStore.projects.first?.id)
        let sampleTask3 = dataStore.tasks.last ?? Task(title: "Задача с высоким приоритетом", dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, projectID: TaskProject.inbox.id, priority: 3)


        return List {
            PreviewWrapper(task: sampleTask1)
            PreviewWrapper(task: sampleTask2)
            PreviewWrapper(task: sampleTask3)
            PreviewWrapper(task: Task(title: "Задача без даты и проекта (входящие)", projectID: TaskProject.inbox.id))
        }
        .environmentObject(dataStore)
    }
}

