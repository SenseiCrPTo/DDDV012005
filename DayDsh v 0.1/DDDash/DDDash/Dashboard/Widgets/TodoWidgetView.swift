import SwiftUI

struct TodoWidgetView: View {
    let todos: [String]
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.widgetBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderRed, lineWidth: 1)
                )
            VStack {
                Text("todo")
                    .font(.headline)
                    .foregroundColor(.mainText)
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
    }
}
