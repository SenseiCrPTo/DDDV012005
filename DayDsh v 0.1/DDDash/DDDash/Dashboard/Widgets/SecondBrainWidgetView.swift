import SwiftUI

struct SecondBrainWidgetView: View {
    let note: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.widgetBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderRed, lineWidth: 1)
                )
            VStack {
                Text("secondbrain")
                    .font(.headline)
                    .foregroundColor(.mainText)
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding()
        }
        .frame(minHeight: 140)
    }
}
