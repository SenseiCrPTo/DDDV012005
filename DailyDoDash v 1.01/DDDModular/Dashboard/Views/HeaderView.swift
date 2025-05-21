import SwiftUI

struct HeaderView: View {
    let appTitle: String

    var body: some View {
        Text(appTitle)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .center) // Центрируем заголовок
            .padding(.vertical, 10) // Добавляем немного отступа
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(appTitle: "DayDash")
    }
}
