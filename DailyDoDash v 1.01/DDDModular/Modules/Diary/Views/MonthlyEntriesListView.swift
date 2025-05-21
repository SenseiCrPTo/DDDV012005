import SwiftUI

struct MonthlyEntriesListView: View {
    let monthDate: Date
    @EnvironmentObject var diaryDataStore: DiaryDataStore // <--- ИЗМЕНЕНО

    // init(monthDate: Date, diaryDataStore: DiaryDataStore) { ... } // <--- УДАЛИТЬ init

    private var monthYearFormatter: DateFormatter { /* Твой код */ DateFormatter() }
    private var entriesForMonth: [DiaryEntry] { /* Твой код, использующий diaryDataStore */ return [] }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Text("Записи в \(monthDate, formatter: monthYearFormatter):").font(.headline).padding(.vertical, 5) // Можно убрать, если заголовок в родительском View
            if entriesForMonth.isEmpty {
                Text("Нет записей в выбранном месяце.").foregroundColor(.gray).padding(.vertical).frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(entriesForMonth.indices, id: \.self) { index in
                        let entry = entriesForMonth[index]
                        // DiaryEntryRowView должен быть обновлен (либо для @EnvironmentObject, либо получать moodSettings)
                        DiaryEntryRowView(entry: entry, moodSettings: diaryDataStore.moodSettings)
                        if index < entriesForMonth.count - 1 { Divider().padding(.leading, 20) }
                    }
                }
            }
        }
    }
}

struct MonthlyEntriesListView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            MonthlyEntriesListView(monthDate: Date())
                .environmentObject(DiaryDataStore.preview) // <--- ИЗМЕНЕНО
                .padding()
        }
    }
}
