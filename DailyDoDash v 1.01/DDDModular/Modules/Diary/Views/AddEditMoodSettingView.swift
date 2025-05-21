import SwiftUI

struct AddEditMoodSettingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var diaryDataStore: DiaryDataStore // <--- ДОБАВИТЬ

    var moodToEdit: MoodSetting?

    @State private var name: String
    @State private var iconName: String
    @State private var selectedColor: Color
    @State private var ratingValue: Int
    // @State private var isDefault: Bool // Обычно isDefault не редактируется пользователем

    private var isEditing: Bool { moodToEdit != nil }
    private let defaultIcon = "face.smiling" // Иконка по умолчанию для нового

    // init(diaryDataStore: DiaryDataStore, moodToEdit: MoodSetting? = nil) // <--- УДАЛИТЬ diaryDataStore
    init(moodToEdit: MoodSetting? = nil) {
        self.moodToEdit = moodToEdit
        if let mood = moodToEdit {
            _name = State(initialValue: mood.name)
            _iconName = State(initialValue: mood.iconName ?? defaultIcon)
            _selectedColor = State(initialValue: mood.color ?? .blue) // Используем .color
            _ratingValue = State(initialValue: mood.ratingValue)
        } else {
            _name = State(initialValue: "")
            _iconName = State(initialValue: defaultIcon)
            _selectedColor = State(initialValue: .blue)
            _ratingValue = State(initialValue: 0)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Настроение") {
                    TextField("Название", text: $name)
                    // Здесь можно добавить Picker для иконки, если нужно
                    TextField("SF Symbol имя иконки (опционально)", text: $iconName)
                        .autocapitalization(.none)
                    ColorPicker("Цвет", selection: $selectedColor, supportsOpacity: false)
                    Stepper("Оценка настроения: \(ratingValue)", value: $ratingValue, in: -10...10)
                }
            }
            .navigationTitle(isEditing ? "Редактировать" : "Новое настроение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") { saveMoodSetting() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveMoodSetting() {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !finalName.isEmpty else { return }

        let finalIconName = iconName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalColorHex = selectedColor.toHex() // ColorExtension должен быть доступен

        if let existingMood = moodToEdit {
            var updatedMood = existingMood
            updatedMood.name = finalName
            updatedMood.iconName = finalIconName
            updatedMood.colorHex = finalColorHex
            updatedMood.ratingValue = ratingValue
            diaryDataStore.updateMoodSetting(updatedMood)
        } else {
            diaryDataStore.addMoodSetting(name: finalName, iconName: finalIconName, colorHex: finalColorHex, ratingValue: ratingValue)
        }
        dismiss()
    }
}

struct AddEditMoodSettingView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditMoodSettingView()
            .environmentObject(DiaryDataStore.preview) // <--- ДОБАВИТЬ
    }
}
