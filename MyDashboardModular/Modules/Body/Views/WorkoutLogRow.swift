import SwiftUI

struct WorkoutLogRow: View {
    let log: WorkoutLog
    let types: [WorkoutType]

    private var typeName: String {
        types.first { $0.id == log.workoutTypeID }?.name ?? "Тренировка"
    }

    private var durationString: String {
        guard let duration = log.duration, duration > 0 else { return "" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated // "1 ч 25 мин"
        return formatter.string(from: duration) ?? ""
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(log.date, style: .date), \(log.date, style: .time)")
                    .font(.headline)
                Text(typeName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let notes = log.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            Spacer()
            if !durationString.isEmpty {
                Text(durationString)
                    .font(.callout) // Сделал чуть крупнее для заметности
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4) // Добавил небольшой отступ
    }
}

// Для превью WorkoutLogRow, если он нужен отдельно
/*
struct WorkoutLogRow_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLog = BodyDataStore.preview.workoutLogs.first ?? WorkoutLog(date: Date(), workoutTypeID: BodyDataStore.preview.workoutTypes.first?.id, duration: 3600, notes: "Пример лога")
        let sampleTypes = BodyDataStore.preview.workoutTypes
        
        List { // Оборачиваем в List для корректного отображения в превью
            WorkoutLogRow(log: sampleLog, types: sampleTypes)
        }
    }
}
*/
