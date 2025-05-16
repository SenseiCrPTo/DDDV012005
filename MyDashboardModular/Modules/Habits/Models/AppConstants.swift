// MyDashboardModular/Shared/Utils/AppConstants.swift (или где вы его создали)
import Foundation
import SwiftUI // Нужно для Color

struct AppConstants {
    
    struct Icons {
        static let habitIcons: [String] = [
            // Общие
            "star.fill", "heart.fill", "flame.fill", "leaf.fill", "drop.fill",
            "bolt.fill", "bell.fill", "tag.fill", "bookmark.fill", "flag.fill",
            "moon.fill", "sun.max.fill", "cloud.fill", "wind", "snowflake",
            "figure.walk", "figure.run", "figure.cooldown", "figure.yoga", "figure.pool.swim",
            "bicycle", "sportscourt.fill", "dumbbell.fill",
            // Продуктивность и работа
            "briefcase.fill", "desktopcomputer", "laptopcomputer", "keyboard.fill", "printer.fill",
            "pencil.and.outline", "doc.text.fill", "folder.fill", "calendar", "alarm.fill",
            "chart.bar.fill", "chart.pie.fill", "arrow.up.right.circle.fill", "arrow.down.left.circle.fill",
            // Хобби и обучение
            "book.fill", "books.vertical.fill", "graduationcap.fill", "music.mic", "guitars.fill", // УБЕДИТЕСЬ, ЧТО ЭТА СТРОКА ПРАВИЛЬНО ЗАВЕРШЕНА
            "paintbrush.pointed.fill", "camera.fill", "film.fill", "gamecontroller.fill",          // И ЭТА
            // Дом и быт
            "house.fill", "bed.double.fill", "fork.knife", "cup.and.saucer.fill", "cart.fill",
            "wrench.and.screwdriver.fill", "lightbulb.fill", "trash.fill",
            // Здоровье и уход
            "brain.head.profile", "lungs.fill", "pills.fill", "bandage.fill", "cross.case.fill",
            // Финансы
            "creditcard.fill", "banknote.fill", "dollarsign.circle.fill", "bitcoinsign.circle.fill",
            // Другое
            "pawprint.fill", "airplane", "car.fill", "tram.fill", "gift.fill",
            "hourglass", "map.fill", "person.2.fill", "phone.fill", "message.fill",
            "mic.fill", "speaker.wave.2.fill", "slider.horizontal.3", "gearshape.fill",
            "nosign"
        ] // <--- Убедитесь, что здесь нет лишних символов или разрывов строк внутри кавычек
        
        // ИСПРАВЛЕНО: Добавим defaultHabitIcon, если он отсутствовал
        static let defaultHabitIcon: String = "star.fill"
    } // <--- Закрывающая скобка для struct Icons
    
    // ИСПРАВЛЕНО: Убедимся, что struct Colors определена правильно
    struct Colors {
        static let predefinedHabitColors: [Color] = [
            .red, .orange, .yellow, .green, .mint, .teal, .cyan,
            .blue, .indigo, .purple, .pink, .brown, Color(UIColor.systemGray2) // Добавил systemGray2 для примера
        ]
        
        static let defaultHabitColor: Color = .blue // Цвет по умолчанию
    } // <--- Закрывающая скобка для struct Colors
    
} // <--- Закрывающая скобка для struct AppConstants
