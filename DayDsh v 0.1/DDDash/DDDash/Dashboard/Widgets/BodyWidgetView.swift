import SwiftUI

struct BodyWidgetView: View {
    let info: String
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("widgetBorderRed"), lineWidth: 1)
                )
            VStack(alignment: .center, spacing: 0) {
                Text("body")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 18)
                Spacer()
                Text(info)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
        }
    }
}
