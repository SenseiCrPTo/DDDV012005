import SwiftUI

struct TodoWidgetView: View {
    let todos: [String]
    @State private var pressed = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(pressed ? Color.yellow.opacity(0.3) : Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("borderRed"), lineWidth: 1)
                )
                .scaleEffect(pressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.18, dampingFraction: 0.75), value: pressed)
            VStack {
                Text("todo")
                    .font(.headline)
                    .foregroundColor(Color("mainText"))
                ForEach(todos.prefix(2), id: \.self) { todo in
                    Text(todo)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
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
