import SwiftUI

struct MoneyWidgetView: View {
    let amount: Double
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("widgetBorderRed"), lineWidth: 1)
                )
            VStack(alignment: .center, spacing: 0) {
                Text("money")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 18)
                Spacer()
                Text("\(Int(amount)) ₽")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.bottom, 16)
            }
        }
    }
}
