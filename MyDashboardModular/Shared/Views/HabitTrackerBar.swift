import SwiftUI

struct HabitTrackerBar: View {
    let daysDone: Int
    let totalDays: Int
    let activeColor: Color

    var body: some View {
        HStack(spacing: 4) { // spacing: 3 или 4 - на твой вкус
            ForEach(0..<totalDays, id: \.self) { index in
                Circle()
                    .fill(index < daysDone ? activeColor : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10) // Размер можно изменить
            }
        }
    }
}
