import SwiftUI

struct MetricRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray) // В твоем коде было .gray, оставляю
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
