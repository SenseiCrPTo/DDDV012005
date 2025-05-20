import SwiftUI

struct TodoWidgetView: View {
    let todos: [String]
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("widgetBorderRed"), lineWidth: 1)
                )
            VStack(alignment: .center, spacing: 0) {
                Text("todo")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 18)
                Spacer()
                ForEach(todos.prefix(2), id: \.self) { todo in
                    Text(todo)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
            }
        }
    }
}
