import SwiftUI

struct HabitWidgetView: View {
    let habit: String
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("widgetBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color("widgetBorderBlue"), lineWidth: 1)
                )
            VStack(alignment: .center, spacing: 0) {
                Text("habit")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 18)
                Spacer()
                Text(habit)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
            }
        }
    }
}
