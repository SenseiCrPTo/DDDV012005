import SwiftUI

struct MoneyWidgetView: View {
    let amount: Double
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.widgetBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.borderRed, lineWidth: 1)
                )
            VStack {
                Text("money")
                    .font(.headline)
                    .foregroundColor(.mainText)
                Text("\(Int(amount)) ₽")
                    .font(.title2.bold())
                    .foregroundColor(.mainText)
            }
            .padding()
        }
        .frame(minHeight: 140)
    }
}
