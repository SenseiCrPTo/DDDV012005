import SwiftUI
import Charts // Этот импорт здесь КРИТИЧЕН

// Использует MonthlyDataPoint из Modules/Finances/Models/
struct ClearChartView: View {
    let data: [MonthlyDataPoint]
    var xAxisLabel: String = "Период" // Можно менять в зависимости от контекста

    var body: some View {
        Chart {
            ForEach(data) { dataPoint in
                LineMark(
                    x: .value(xAxisLabel, dataPoint.month), // Используем month как строку для оси X
                    y: .value("Сумма", dataPoint.value)
                )
                .foregroundStyle(by: .value("Тип", dataPoint.type))

                PointMark(
                    x: .value(xAxisLabel, dataPoint.month),
                    y: .value("Сумма", dataPoint.value)
                )
                .foregroundStyle(by: .value("Тип", dataPoint.type))
                .symbolSize(dataPoint.value > 0 ? 50 : 0) // Показываем точки только если значение больше 0
            }
        }
        .chartForegroundStyleScale(domain: ["Доход", "Расход", "Накопления"], range: [Color.green, Color.red, Color.blue])
        .frame(height: 150) // Немного увеличил высоту для лучшей читаемости
        .chartXAxis {
            // Показываем метки для каждого уникального месяца/дня, если их не слишком много,
            // иначе можно использовать .automatic(desiredCount:)
            AxisMarks(values: .automatic(desiredCount: data.map { $0.month }.unique.count / 2))
        }
        .chartYAxis {
            AxisMarks(preset: .aligned, values: .automatic(desiredCount: 4)) // Автоматические метки по Y
        }
    }
}
