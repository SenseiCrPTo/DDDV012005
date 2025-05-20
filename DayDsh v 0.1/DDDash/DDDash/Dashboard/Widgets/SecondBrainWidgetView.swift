import SwiftUI

struct SecondBrainWidgetView: View {
    let note: String
    @State private var pressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(pressed ? Color.purple.opacity(0.17) : Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("borderRed"), lineWidth: 1)
                )
                .scaleEffect(pressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.18, dampingFraction: 0.75), value: pressed)
            VStack {
                Text("secondbrain")
                    .font(.headline)
                    .foregroundColor(Color("mainText"))
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
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
