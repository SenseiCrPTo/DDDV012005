import SwiftUI

// Использует WorkoutSet из Modules/Body/Models/
struct WorkoutSetRow: View {
    @Binding var set: WorkoutSet
    var onEditTap: () -> Void // Замыкание для обработки нажатия на редактирование

    var body: some View {
        HStack {
            Button {
                set.isCompleted.toggle()
                set.completionTimestamp = set.isCompleted ? Date() : nil
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle()) // Чтобы кнопка не занимала всю строку

            Text(set.displayString)
            Spacer()
            Button(action: onEditTap) {
                Image(systemName: "pencil.circle")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
