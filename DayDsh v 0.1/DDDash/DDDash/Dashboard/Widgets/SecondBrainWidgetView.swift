import SwiftUI

struct SecondBrainWidgetView: View {
    let note: String
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("widgetBorderRed"), lineWidth: 1)
                )
            VStack(alignment: .center, spacing: 0) {
                Text("secondbrain")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 18)
                Spacer()
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
        }
    }
}
