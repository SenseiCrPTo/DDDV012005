import SwiftUI

struct HabitWidgetView: View {
    let habit: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.widgetBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderBlue, lineWidth: 1)
                )
            VStack {
                Text("habit")
                    .font(.headline)
                    .foregroundColor(.mainText)
                Text(habit)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .frame(minHeight: 140)
    }
}
