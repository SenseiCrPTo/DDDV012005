import SwiftUI

struct HabitWidgetView: View {
    let habit: String
    @State private var pressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(pressed ? Color("habitAccent") : Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("borderBlue"), lineWidth: 1)
                )
                .scaleEffect(pressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.18, dampingFraction: 0.75), value: pressed)
            VStack {
                Text("habit")
                    .font(.headline)
                    .foregroundColor(Color("mainText"))
                Text(habit)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .frame(minHeight: 140)
        .onTapGesture {
            pressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                pressed = false
            }
        }
    }
}
