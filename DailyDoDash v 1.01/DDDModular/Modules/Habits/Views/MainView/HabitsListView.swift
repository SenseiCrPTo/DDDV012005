import SwiftUI

struct HabitsListView: View {
    @EnvironmentObject var habitDataStore: HabitDataStore // Получаем из окружения
    
    @State private var showingAddEditSheet = false
    @State private var habitToEdit: Habit? = nil // Для определения, создаем новую или редактируем существующую

    // Фильтрованные массивы для отображения активных и архивных привычек
    private var activeHabits: [Habit] {
        habitDataStore.habits.filter { !$0.isArchived }
    }
    private var archivedHabits: [Habit] {
        habitDataStore.habits.filter { $0.isArchived }
    }

    var body: some View {
        // NavigationView должен быть здесь, если HabitsListView является
        // самостоятельным экраном или корнем для вкладки.
        // Если HabitsMiniAppView уже обернут в NavigationView (например, в MainDashboardView),
        // то этот NavigationView может быть лишним или его нужно будет настроить.
        // Пока оставляем, так как это типично для списка с деталями.
        NavigationView {
            List {
                // Сообщение, если вообще нет привычек
                if habitDataStore.habits.isEmpty {
                    Text("Нет привычек. Нажми '+' для добавления первой привычки.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 50)
                        .listRowSeparator(.hidden) // Скрываем разделитель для этого текстового блока
                } else {
                    // Секция для активных привычек
                    if !activeHabits.isEmpty {
                        Section(header: Text("Активные (\(activeHabits.count))")) {
                            ForEach(activeHabits) { habit in
                                // HabitRowView теперь сам возьмет habitDataStore из окружения
                                HabitRowView(habit: habit)
                                    .contentShape(Rectangle()) // Делаем всю строку кликабельной
                                    .onTapGesture {
                                        self.habitToEdit = habit // Устанавливаем привычку для редактирования
                                        self.showingAddEditSheet = true
                                        print("HabitsListView: Нажатие для редактирования привычки '\(habit.name)' (ID: \(habit.id))")
                                    }
                                    // Добавляем контекстное меню для архивации/разархивации и удаления
                                    .contextMenu {
                                        Button {
                                            habitDataStore.archiveHabit(habit, shouldArchive: true)
                                        } label: {
                                            Label("Архивировать", systemImage: "archivebox")
                                        }
                                        Button(role: .destructive) {
                                            habitDataStore.deleteHabitById(habit.id)
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }
                            .onDelete(perform: deleteActiveHabits) // Для удаления свайпом
                        }
                    } else if archivedHabits.isEmpty { // Если активных нет, но и архивных тоже нет (значит, список habits не пуст, но все удалены?)
                        // Эта ситуация маловероятна, если habits.isEmpty проверяется выше.
                        // Но если бы мы хотели показать сообщение "Нет активных привычек", оно было бы здесь.
                    }

                    // Секция для архивных привычек
                    if !archivedHabits.isEmpty {
                        Section(header: Text("Архив (\(archivedHabits.count))")) {
                            ForEach(archivedHabits) { habit in
                                HabitRowView(habit: habit)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        self.habitToEdit = habit // Также позволяем "редактировать" (просматривать/разархивировать)
                                        self.showingAddEditSheet = true
                                        print("HabitsListView: Нажатие для просмотра/редактирования архивной привычки '\(habit.name)' (ID: \(habit.id))")
                                    }
                                    .contextMenu {
                                        Button {
                                            habitDataStore.archiveHabit(habit, shouldArchive: false)
                                        } label: {
                                            Label("Разархивировать", systemImage: "arrow.up.bin")
                                        }
                                        Button(role: .destructive) {
                                            habitDataStore.deleteHabitById(habit.id)
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }
                            .onDelete(perform: deleteArchivedHabits) // Для удаления свайпом
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle()) // Стиль списка
            .navigationTitle("Мои Привычки")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // Стандартная кнопка для включения/выключения режима удаления строк
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.habitToEdit = nil // Сбрасываем habitToEdit для создания новой привычки
                        self.showingAddEditSheet = true
                        print("HabitsListView: Нажатие для добавления новой привычки.")
                    } label: {
                        Label("Добавить", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddEditSheet, onDismiss: {
                // Опционально: можно сбросить habitToEdit здесь, если нужно,
                // но обычно это не требуется, так как кнопка "+" уже делает nil.
                // self.habitToEdit = nil
                print("HabitsListView: Sheet закрыт. habitToEdit is \(self.habitToEdit == nil ? "nil" : "set").")
            }) {
                // AddEditHabitView теперь сам возьмет habitDataStore из окружения.
                // Передаем только habitToEdit (который может быть nil для новой привычки).
                AddEditHabitView(habitToEdit: self.habitToEdit)
            }
        }
        // .navigationViewStyle(.stack) // Используй .stack, если это основной NavigationView в приложении
                                      // или если есть проблемы с двойными NavigationView.
                                      // Если это вложено в TabView, .stack обычно хороший выбор.
    }

    // Метод для удаления активных привычек (вызывается onDelete из List)
    private func deleteActiveHabits(at offsets: IndexSet) {
        // Получаем ID привычек, которые нужно удалить, на основе offsets из отфильтрованного массива activeHabits
        let idsToDelete = offsets.map { activeHabits[$0].id }
        
        // Удаляем каждую привычку из DataStore по ее ID
        for id in idsToDelete {
            print("HabitsListView: Попытка удаления активной привычки с ID: \(id)")
            habitDataStore.deleteHabitById(id)
        }
    }

    // Метод для удаления архивных привычек (вызывается onDelete из List)
    private func deleteArchivedHabits(at offsets: IndexSet) {
        let idsToDelete = offsets.map { archivedHabits[$0].id }
        for id in idsToDelete {
            print("HabitsListView: Попытка удаления архивной привычки с ID: \(id)")
            habitDataStore.deleteHabitById(id)
        }
    }
}

// Previews для HabitsListView
struct HabitsListView_Previews: PreviewProvider {
    static var previews: some View {
        // Используем моковый HabitDataStore.preview
        HabitsListView()
            .environmentObject(HabitDataStore.preview)
    }
}
