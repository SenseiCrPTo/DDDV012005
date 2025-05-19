import SwiftUI
import Charts

struct MoneyWidgetView: View {
    @EnvironmentObject var dataStore: FinancialDataStore

    var body: some View {
        NavigationLink(destination: MoneyMiniAppView()) { // <--- ИСПРАВЛЕНО
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Финансы")
                        .font(.system(.headline, design: .rounded).bold())
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    Spacer()
                    Picker("Период", selection: $dataStore.selectedAnalyticsPeriod) {
                        ForEach(TimePeriodSelection.allCases) { period in
                            Text(period.shortLabel).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, -8)
                }

                if dataStore.periodicalChartData.filter({ $0.value > 0 }).isEmpty && dataStore.selectedAnalyticsPeriod != .allTime {
                    Text("Нет данных за выбранный период.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 100, alignment: .center)
                        .frame(maxWidth: .infinity)
                } else {
                    let xAxisLabel: String = {
                        switch dataStore.selectedAnalyticsPeriod {
                        case .week, .month: return "День"
                        case .year, .allTime: return "Месяц"
                        }
                    }()
                    ClearChartView(data: dataStore.periodicalChartData, xAxisLabel: xAxisLabel) // ClearChartView получает данные, а не DataStore
                        .frame(height: 100).padding(.bottom, 2)
                }
                MetricRow(label: "Доход (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.incomeForSelectedPeriodString)
                MetricRow(label: "Расход (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.expensesForSelectedPeriodString, valueColor: .red)
                MetricRow(label: "Накопления (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.savingsForSelectedPeriodString, valueColor: .blue)
                MetricRow(label: "Общий баланс:", value: dataStore.totalBalanceString, valueColor: .primary)
            }
            .padding(10).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle()).background(Material.thin).cornerRadius(16).foregroundColor(.primary)
        }
    }
}
struct MoneyWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyWidgetView().environmentObject(FinancialDataStore.preview)
            .padding().previewLayout(.fixed(width: 200, height: 230)).background(Color.gray.opacity(0.1))
    }
}
