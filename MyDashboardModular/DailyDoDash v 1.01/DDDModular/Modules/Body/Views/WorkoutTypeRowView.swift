import SwiftUI

struct WorkoutTypeRowView: View {
    let type: WorkoutType
    // Мы передадим замыкания для действий, чтобы эта View не зависела напрямую от состояния родителя
    var onEdit: (WorkoutType) -> Void
    var onDeleteAttempt: (WorkoutType) -> Void

    var body: some View {
        HStack {
            if let iconName = type.iconName, !iconName.isEmpty {
                Image(systemName: iconName)
                    .frame(width: 25, alignment: .center)
            } else {
                Image(systemName: "figure.mixed.cardio") // Иконка по умолчанию
                    .frame(width: 25, alignment: .center)
                    .foregroundColor(.gray)
            }
            Text(type.name)
        }
        .contentShape(Rectangle()) // Делает всю HStack кликабельной для onTapGesture
        .onTapGesture {
            onEdit(type)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDeleteAttempt(type)
            } label: {
                Label("Удалить", systemImage: "trash.fill")
            }

            Button {
                onEdit(type)
            } label: {
                Label("Редактировать", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
}
