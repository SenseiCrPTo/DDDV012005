import SwiftUI

struct AddEditDiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryDataStore: DiaryDataStore
    
    var entryToEdit: DiaryEntry? // Приходит извне (nil для новой записи)
    
    // Локальные состояния для полей формы
    @State private var entryDate: Date
    @State private var entryTitle: String
    @State private var entryText: String
    @State private var selectedMoodID: UUID?
    @State private var isBookmarked: Bool

    // Это свойство определяет, находимся ли мы в режиме редактирования
    // Оно должно быть доступно для navigationTitleString
    private var isEditing: Bool { entryToEdit != nil }
    
    // Это свойство будет использоваться для заголовка
    private var navigationTitleString: String {
        isEditing ? "Редактировать запись" : "Новая запись"
    }
    
    init(entryToEdit: DiaryEntry? = nil) {
        self.entryToEdit = entryToEdit
        
        // Инициализация @State переменных
        if let entry = entryToEdit {
            _entryDate = State(initialValue: entry.date)
            _entryTitle = State(initialValue: entry.title ?? "")
            _entryText = State(initialValue: entry.text)
            _selectedMoodID = State(initialValue: entry.moodID)
            _isBookmarked = State(initialValue: entry.isBookmarked)
        } else {
            _entryDate = State(initialValue: Date())
            _entryTitle = State(initialValue: "")
            _entryText = State(initialValue: "")
            _selectedMoodID = State(initialValue: nil)
            _isBookmarked = State(initialValue: false)
        }
    }
    
    // Содержимое для Picker настроения
    private var moodPickerContent: some View {
        // Используем diaryDataStore из @EnvironmentObject
        ForEach(diaryDataStore.moodSettings.sorted(by: { $0.name < $1.name })) { moodSetting in
            HStack {
                if let iconName = moodSetting.iconName, !iconName.isEmpty {
                    Image(systemName: iconName)
                        .foregroundColor(moodSetting.color ?? .primary) // Используем .color
                } else if let color = moodSetting.color { // Используем .color
                    Circle().fill(color).frame(width:12, height:12)
                } else {
                    Circle().fill(Color.gray.opacity(0.3)).frame(width:12,height:12)
                }
                Text(moodSetting.name)
                Text("(\(moodSetting.ratingValue))").font(.caption).foregroundColor(.gray)
            }
            .tag(moodSetting.id as UUID?) // Тег для Picker
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дата и настроение")) {
                    DatePicker("Дата записи", selection: $entryDate, displayedComponents: .date)
                    Picker("Настроение", selection: $selectedMoodID) {
                        Text("Не выбрано").tag(nil as UUID?) // Опция "Не выбрано"
                        moodPickerContent // Используем вынесенное View
                    }
                }
                
                Section(header: Text("Запись")) {
                    TextField("Заголовок (опционально)", text: $entryTitle)
                    ZStack(alignment: .topLeading) {
                        if entryText.isEmpty {
                            Text("Что у вас на уме?")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8) // Стандартные отступы для TextEditor
                                .padding(.leading, 5)
                                .allowsHitTesting(false) // Чтобы не мешать TextEditor
                        }
                        TextEditor(text: $entryText)
                            .frame(minHeight: 200, maxHeight: .infinity)
                    }
                }
                Section {
                    Toggle("Добавить в закладки", isOn: $isBookmarked)
                }
            }
            .navigationTitle(navigationTitleString) // <--- ИСПОЛЬЗУЕМ navigationTitleString
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        let trimmedTitle = entryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalText = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Запись не может быть абсолютно пустой
        guard !finalText.isEmpty else {
            print("AddEditDiaryEntryView: Текст записи не может быть пустым.")
            // Можно показать алерт пользователю
            return
        }

        let finalTitle = trimmedTitle.isEmpty ? nil : trimmedTitle
        
        if let existingEntry = entryToEdit {
            var updatedEntry = existingEntry
            updatedEntry.date = entryDate
            updatedEntry.title = finalTitle
            updatedEntry.text = finalText
            updatedEntry.moodID = selectedMoodID
            updatedEntry.isBookmarked = isBookmarked
            updatedEntry.lastModifiedTimestamp = Date() // Обновляем время изменения
            diaryDataStore.updateEntry(updatedEntry)
        } else {
            diaryDataStore.addEntry(
                date: entryDate,
                title: finalTitle,
                text: finalText,
                moodID: selectedMoodID,
                isBookmarked: isBookmarked
            )
        }
    }
}

struct AddEditDiaryEntryView_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем моковый DataStore для превью
        let previewDataStore = DiaryDataStore.preview // Используем .preview из расширения
        
        // Для новой записи
        AddEditDiaryEntryView()
            .environmentObject(previewDataStore)
            .previewDisplayName("Новая Запись")

        // Для редактирования (если есть записи в previewDataStore)
        // if let entryToEdit = previewDataStore.entries.first {
        //     AddEditDiaryEntryView(entryToEdit: entryToEdit)
        //         .environmentObject(previewDataStore)
        //         .previewDisplayName("Редактирование Записи")
        // }
    }
}
