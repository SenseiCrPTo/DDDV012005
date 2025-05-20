import SwiftUI

struct BodyWidgetView: View {
    let info: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.widgetBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderRed, lineWidth: 1)
                )
            VStack {
                Text("body")
                    .font(.headline)
                    .foregroundColor(.mainText)
                Text(info)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .frame(minHeight: 140)
    }
}
