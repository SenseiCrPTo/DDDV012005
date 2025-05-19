// MyDashboardModular/Modules/Habits/Views/Components/AddEditHabitView.swift
import SwiftUI

struct AddEditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var habitDataStore: HabitDataStore

    let habitToEdit: Habit?

    @State private var name: String
    @State private var descriptionText: String
    @State private var selectedIconName: String
    @State private var selectedColor: Color
    @State private var showOnWidget: Bool

    @State private var selectedBaseFrequencyType: HabitFrequencyBaseType
    @State private var specificDaysOfWeek: Set<Int>
    @State private var timesPerWeekCount: Int
    @State private var everyXDaysCount: Int
    
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date
    @State private var reminderSpecificDays: Set<Int> // Это может быть использовано для напоминаний, если частота не daily


    private var isEditing: Bool { habitToEdit != nil }
    let predefinedSystemColors: [Color] = AppConstants.Colors.predefinedHabitColors

    // ИСПРАВЛЕНО: Полная реализация daySymbols
    var daySymbols: [(symbol: String, dayOfWeek: Int)] {
        let calendar = Calendar.current
        // veryShortStandaloneWeekdaySymbols для независимых однобуквенных названий,
        // которые не меняются в зависимости от того, стоят они в начале или середине.
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        var dayData: [(symbol: String, dayOfWeek: Int)] = []
        
        // calendar.firstWeekday: 1 = Воскресенье, 2 = Понедельник, и т.д.
        // symbols: массив из 7 строк, начиная с Воскресенья (индекс 0) до Субботы (индекс 6)
        for i in 0..<7 {
            // Вычисляем индекс в symbols так, чтобы первым шел день, указанный в calendar.firstWeekday
            let displayOrderIndex = (calendar.firstWeekday - 1 + i + 7) % 7
            let symbol = symbols[displayOrderIndex]
            // actualDayOfWeek всегда будет 1 для Воскресенья, ..., 7 для Субботы, независимо от firstWeekday
            let actualDayOfWeek = displayOrderIndex + 1
            dayData.append((symbol: symbol, dayOfWeek: actualDayOfWeek))
        }
        return dayData
    }

    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        
        if let habit = habitToEdit {
            _name = State(initialValue: habit.name)
            _descriptionText = State(initialValue: habit.description ?? "")
            _selectedIconName = State(initialValue: habit.iconName)
            _selectedColor = State(initialValue: Color(hex: habit.colorHex ?? "") ?? AppConstants.Colors.defaultHabitColor)
            _showOnWidget = State(initialValue: habit.showOnWidget)
            _selectedBaseFrequencyType = State(initialValue: habit.frequency.baseType)
            
            var initialSpecificDays: Set<Int> = []
            var initialTimesPerWeek = 1
            var initialEveryXDays = 2

            switch habit.frequency {
            case .specificDaysOfWeek(let days): initialSpecificDays = days
            case .timesPerWeek(let count): initialTimesPerWeek = count
            case .everyXDays(let days): initialEveryXDays = days
            case .daily: break
            }
            _specificDaysOfWeek = State(initialValue: initialSpecificDays)
            _timesPerWeekCount = State(initialValue: initialTimesPerWeek)
            _everyXDaysCount = State(initialValue: initialEveryXDays)
            
            _reminderEnabled = State(initialValue: habit.reminderTime != nil)
            _reminderTime = State(initialValue: habit.reminderTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!)
            _reminderSpecificDays = State(initialValue: habit.reminderDays ?? [])
        } else {
            _name = State(initialValue: "")
            _descriptionText = State(initialValue: "")
            _selectedIconName = State(initialValue: AppConstants.Icons.habitIcons.first ?? AppConstants.Icons.defaultHabitIcon)
            _selectedColor = State(initialValue: AppConstants.Colors.defaultHabitColor)
            _showOnWidget = State(initialValue: true)
            _selectedBaseFrequencyType = State(initialValue: .daily)
            _specificDaysOfWeek = State(initialValue: [])
            _timesPerWeekCount = State(initialValue: 1)
            _everyXDaysCount = State(initialValue: 2)
            _reminderEnabled = State(initialValue: false)
            _reminderTime = State(initialValue: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!)
            _reminderSpecificDays = State(initialValue: [])
        }
    }

    var body: some View {
        NavigationView {
            Form {
                generalSection
                appearanceSection
                frequencySection
                additionalSection
            }
            .navigationTitle(Text(isEditing ? "Редактировать привычку" : "Новая привычка"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Сохранить" : "Добавить") {
                        saveHabit()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                             (selectedBaseFrequencyType == .specificDaysOfWeek && specificDaysOfWeek.isEmpty))
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // --- Секции формы ---
    @ViewBuilder private var generalSection: some View {
        Section("Основное") {
            TextField("Название привычки", text: $name)
            TextField("Описание (необязательно)", text: $descriptionText, axis: .vertical)
                .lineLimit(3...5)
        }
    }

    @ViewBuilder private var appearanceSection: some View {
        Section("Внешний вид") {
            iconSelector
            colorSelector
        }
    }
    
    @ViewBuilder private var iconSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(AppConstants.Icons.habitIcons, id: \.self) { icon in
                    Image(systemName: icon).font(.title2).frame(width: 40, height: 40).padding(4)
                        .background(selectedIconName == icon ? selectedColor.opacity(0.3) : Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .foregroundColor(selectedIconName == icon ? selectedColor : .primary.opacity(0.7))
                        .onTapGesture { selectedIconName = icon }
                }
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder private var colorSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(predefinedSystemColors, id: \.self) { color in
                    Circle().fill(color).frame(width: 30, height: 30).padding(4)
                        .overlay(Circle().stroke(selectedColor.isEqualTo(color) ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 2.5))
                        .onTapGesture { selectedColor = color }
                }
            }
        }
        .padding(.vertical, 4)
        ColorPicker("Свой цвет", selection: $selectedColor, supportsOpacity: false)
    }

    @ViewBuilder private var frequencySection: some View {
        Section("Частота") {
            Picker("Повторять", selection: $selectedBaseFrequencyType.animation()) {
                ForEach(HabitFrequencyBaseType.allCases) { baseType in
                    Text(baseType.rawValue).tag(baseType)
                }
            }

            if selectedBaseFrequencyType == .specificDaysOfWeek {
                HStack(spacing: 4) {
                    ForEach(daySymbols, id: \.dayOfWeek) { dayInfo in // Используем dayOfWeek как ID
                        Text(dayInfo.symbol)
                            .font(.caption).fontWeight(specificDaysOfWeek.contains(dayInfo.dayOfWeek) ? .bold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10).padding(.horizontal, 4)
                            .background(specificDaysOfWeek.contains(dayInfo.dayOfWeek) ? selectedColor.opacity(0.3) : Color(UIColor.systemGray5))
                            .cornerRadius(8)
                            .foregroundColor(specificDaysOfWeek.contains(dayInfo.dayOfWeek) ? selectedColor : .primary)
                            .onTapGesture { toggleDaySelection(dayInfo.dayOfWeek) }
                    }
                }
                .padding(.vertical, 4)
                 if specificDaysOfWeek.isEmpty && selectedBaseFrequencyType == .specificDaysOfWeek {
                    Text("Выберите хотя бы один день").font(.caption).foregroundColor(.red)
               }
            } else if selectedBaseFrequencyType == .timesPerWeek {
                Stepper("\(timesPerWeekCount) раз(а) в неделю", value: $timesPerWeekCount, in: 1...7)
            } else if selectedBaseFrequencyType == .everyXDays {
                Stepper("Каждые \(everyXDaysCount) дн.", value: $everyXDaysCount, in: 1...90)
            }
        }
    }

    @ViewBuilder private var additionalSection: some View {
        Section("Дополнительно") {
            Toggle("Отображать на виджете", isOn: $showOnWidget)
            Toggle("Включить напоминание", isOn: $reminderEnabled.animation())
            if reminderEnabled {
                DatePicker("Время напоминания", selection: $reminderTime, displayedComponents: .hourAndMinute)
                // Здесь можно добавить выбор дней для напоминаний, если это не .specificDaysOfWeek
                // if selectedBaseFrequencyType != .specificDaysOfWeek { ... UI для $reminderSpecificDays ... }
            }
        }
    }

    private func toggleDaySelection(_ dayOfWeek: Int) {
        if specificDaysOfWeek.contains(dayOfWeek) {
            specificDaysOfWeek.remove(dayOfWeek)
        } else {
            specificDaysOfWeek.insert(dayOfWeek)
        }
    }
    
    private func saveHabit() {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !finalName.isEmpty else { return }
        
        var finalFrequency: HabitFrequency
        switch selectedBaseFrequencyType {
        case .daily: finalFrequency = .daily
        case .specificDaysOfWeek:
            guard !specificDaysOfWeek.isEmpty else { return }
            finalFrequency = .specificDaysOfWeek(days: specificDaysOfWeek)
        case .timesPerWeek: finalFrequency = .timesPerWeek(count: timesPerWeekCount)
        case .everyXDays: finalFrequency = .everyXDays(days: everyXDaysCount)
        }

        let finalColorHex = selectedColor.toHex() ?? AppConstants.Colors.defaultHabitColor.toHex() ?? "007AFF"
        let finalDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let finalReminderTime = reminderEnabled ? reminderTime : nil
        // Определяем reminderDays в зависимости от выбранной частоты и включенности напоминаний
        let finalReminderDays: Set<Int>?
        if reminderEnabled {
            if selectedBaseFrequencyType == .specificDaysOfWeek && !specificDaysOfWeek.isEmpty {
                finalReminderDays = specificDaysOfWeek // Напоминать в выбранные дни привычки
            } else if selectedBaseFrequencyType == .daily {
                finalReminderDays = Set(1...7) // Для ежедневной напоминаем каждый день (можно сделать настраиваемым)
            } else {
                finalReminderDays = nil // Для других частот (timesPerWeek, everyXDays) напоминания могут быть только по времени
            }
        } else {
            finalReminderDays = nil
        }


        if var habit = habitToEdit {
            habit.name = finalName
            habit.description = finalDescription
            habit.iconName = selectedIconName
            habit.colorHex = finalColorHex
            habit.frequency = finalFrequency
            habit.showOnWidget = showOnWidget
            habit.reminderTime = finalReminderTime
            habit.reminderDays = finalReminderDays
            
            habitDataStore.updateHabit(habit)
        } else {
            habitDataStore.addHabit(
                name: finalName, description: finalDescription, iconName: selectedIconName,
                colorHex: finalColorHex, frequency: finalFrequency, showOnWidget: showOnWidget,
                reminderTime: finalReminderTime, reminderDays: finalReminderDays
            )
        }
        dismiss()
    }
}

// PreviewProvider остается как у вас
struct AddEditHabitView_Previews: PreviewProvider {
    // ... (код PreviewProvider без изменений из вашего предыдущего файла) ...
    static var previews: some View {
        let previewDataStore = HabitDataStore.preview
        
        AddEditHabitView()
            .environmentObject(previewDataStore)
            .previewDisplayName("Новая привычка")

        AddEditHabitView(habitToEdit: previewDataStore.habits.first ?? Habit(name: "Тест Редакт.", iconName: "pencil", colorHex: "FF00FF"))
            .environmentObject(previewDataStore)
            .previewDisplayName("Редактирование")
    }
}
