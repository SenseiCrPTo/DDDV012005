import SwiftUI
import Charts

struct DiaryStatsView: View {
    @EnvironmentObject var diaryDataStore: DiaryDataStore // <--- ИЗМЕНЕНО
    @State private var displayedMonthInCalendar: Date = Date()
    // Используем ChartTimePeriodLocal из DiaryDataStore или твой глобальный ChartTimePeriod
    @State private var selectedChartPeriod: DiaryDataStore.ChartTimePeriodLocal = .month

    // init(diaryDataStore: DiaryDataStore) { ... } // <--- УДАЛИТЬ init, если он был только для diaryDataStore

    // Твои private var headerView, calendarSectionView, moodStatsSectionView, streaksSectionView
    // должны теперь использовать diaryDataStore из @EnvironmentObject.
    // Убедись, что они это делают, или передавай им необходимые данные.
    private var headerView: some View {
        Text("Статистика Дневника").font(.largeTitle).bold().padding(.bottom).frame(maxWidth: .infinity, alignment: .leading)
    }

    private var calendarSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Календарь записей").font(.title2).bold().padding(.bottom, 5)
            DatePicker("Месяц", selection: $displayedMonthInCalendar, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .onChange(of: displayedMonthInCalendar) { /*newValue*/_ in
                    // Действие при смене месяца, если нужно
                }
            // MonthlyEntriesListView должен использовать @EnvironmentObject
            MonthlyEntriesListView(monthDate: displayedMonthInCalendar)
                .id(displayedMonthInCalendar)
        }
    }
    
    private var moodStatsSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Частые настроения").font(.title2).bold().padding(.bottom, 5)
            let frequentMoods = diaryDataStore.moodFrequency
            if frequentMoods.isEmpty { /* Текст "Нет данных..." */ }
            else { VStack(alignment: .leading, spacing: 8) { ForEach(frequentMoods.prefix(5), id: \.moodSetting.id) { _ in /* Твой HStack */ } } }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var streaksSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Полосы ведения").font(.title2).bold().padding(.bottom, 5)
            let streaks = diaryDataStore.journalStreaks
            HStack(spacing: 20) { /* Твой HStack для отображения streaks.current и streaks.longest */ }
            // ... (остальная логика отображения текста для streaks) ...
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var moodGraphSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("График настроения").font(.title2).bold(); Spacer()
                Picker("Период", selection: $selectedChartPeriod) {
                    ForEach(DiaryDataStore.ChartTimePeriodLocal.allCases) { period in // Используем ChartTimePeriodLocal
                        Text(period.rawValue).tag(period)
                    }
                }.pickerStyle(.segmented).frame(maxWidth: 220)
            }.padding(.bottom, 5)
            
            let chartData = diaryDataStore.dailyMoodRatings(forPeriod: selectedChartPeriod)
            
            if chartData.isEmpty {
                Text("Нет данных для графика...").foregroundColor(.gray).padding().frame(height: 250, alignment: .center).frame(maxWidth: .infinity)
            } else {
                if #available(iOS 16.0, *) {
                    Chart {
                        ForEach(chartData) { dp in
                            LineMark(x: .value("Дата", dp.date, unit: .day), y: .value("Оценка", dp.rating)).interpolationMethod(.catmullRom).foregroundStyle(Color.blue.gradient)
                            PointMark(x: .value("Дата", dp.date, unit: .day), y: .value("Оценка", dp.rating)).foregroundStyle(pointMarkColor(for: dp.rating)).symbolSize(dp.rating == 0 ? 40 : 60)
                        }
                        RuleMark(y: .value("Нейтрально", 0)).foregroundStyle(Color.gray.opacity(0.5)).lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 5]))
                    }
                    .chartXScale(domain: currentChartXDomain ?? (Date().addingTimeInterval(-7*86400)...Date()) ) // currentChartXDomain должен быть определен
                    .chartYScale(domain: -10...10)
                    .chartYAxis { AxisMarks(position: .leading, values: [-10, -5, 0, 5, 10]) { /* ... */ } }
                    .chartXAxis { AxisMarks(preset: .automatic, values: .automatic(desiredCount: 5)) { /* ... */ } }
                    .frame(height: 250).padding(.top)
                } else { Text("Графики доступны на iOS 16+.").foregroundColor(.gray).padding().frame(height: 250, alignment: .center).frame(maxWidth: .infinity) }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Убедись, что currentChartXDomain определено, если оно используется
    private var currentChartXDomain: ClosedRange<Date>? { /* Твоя логика для currentChartXDomain */ return nil }


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                headerView
                calendarSectionView
                Divider().padding(.vertical, 10)
                moodStatsSectionView
                Divider().padding(.vertical, 10)
                streaksSectionView
                Divider().padding(.vertical, 10)
                moodGraphSectionView
            }.padding()
        }
        .navigationTitle("Статистика")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func countSuffix(for count: Int, forms: (one: String, few: String, many: String)) -> String { /* Твой код */ return ""}
    private func pointMarkColor(for rating: Int) -> Color { /* Твой код */ return .black}
}

struct DiaryStatsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DiaryStatsView()
                .environmentObject(DiaryDataStore.preview) // <--- ИЗМЕНЕНО
        }
    }
}
