import SwiftUI

struct MainDashboardView: View {
    // DataStores теперь будут получены из окружения, если они нужны здесь напрямую.
    // Однако, если MainDashboardView просто служит контейнером для виджетов,
    // и каждый виджет сам берет нужный DataStore из окружения,
    // то здесь явные @EnvironmentObject могут и не понадобиться.

    // @EnvironmentObject var habitDataStore: HabitDataStore // Пример, если бы он был нужен прямо в MainDashboardView
    // @EnvironmentObject var diaryDataStore: DiaryDataStore
    // @EnvironmentObject var taskDataStore: TaskDataStore
    // @EnvironmentObject var financeDataStore: FinancialDataStore
    // @EnvironmentObject var bodyDataStore: BodyDataStore

    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // HeaderView, если он не зависит от конкретных DataStore, остается как есть.
                    // Если ему нужны данные, он тоже может использовать @EnvironmentObject.
                    HeaderView(appTitle: "DayDash") // Предполагаем, что appTitle статичен или берется из другого источника
                        .padding(.bottom, 4)

                    LazyVGrid(columns: columns, spacing: 16) {
                        // Виджеты теперь будут брать свои DataStore из окружения.
                        // Им больше не нужно передавать DataStore как параметр.
                        MoneyWidgetView()    // Было: MoneyWidgetView(dataStore: financeDataStore)
                        TasksWidgetView()    // Было: TasksWidgetView(taskDataStore: taskDataStore)
                        BodyWidgetView()     // Было: BodyWidgetView(bodyDataStore: bodyDataStore)
                        DiaryWidgetView()    // Было: DiaryWidgetView(diaryDataStore: diaryDataStore)
                    }

                    HabitWidgetView()        // Было: HabitWidgetView(habitDataStore: habitDataStore)
                        .padding(.top, 8)

                    Spacer() // Занимает доступное пространство внизу
                }
                .padding(.horizontal) // Горизонтальные отступы для всего VStack
                // .padding(.top, 0) // Если не нужен верхний отступ после NavigationView
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea()) // Фон для ScrollView
            .navigationBarHidden(true) // Скрываем стандартный NavigationBar, так как есть HeaderView
        }
        .navigationViewStyle(.stack) // Рекомендуется для основного NavigationView
    }
}

// Previews для MainDashboardView
struct MainDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        MainDashboardView()
            // Для превью нужно предоставить все EnvironmentObjects,
            // которые ожидают MainDashboardView или его дочерние View.
            .environmentObject(HabitDataStore.preview) // Используем моковый store из расширения
            .environmentObject(FinancialDataStore()) // Замени на FinancialDataStore.preview если есть
            .environmentObject(TaskDataStore())      // Замени на TaskDataStore.preview если есть
            .environmentObject(BodyDataStore())      // Замени на BodyDataStore.preview если есть
            .environmentObject(DiaryDataStore())     // Замени на DiaryDataStore.preview если есть
    }
}

// Пример заглушки для HeaderView, если он у тебя в отдельном файле
// Если HeaderView.swift уже есть и не требует изменений, этот код не нужен.
// struct HeaderView: View {
//     let appTitle: String
//     var body: some View {
//         Text(appTitle)
//             .font(.largeTitle)
//             .fontWeight(.bold)
//     }
// }

// Аналогично, MoneyWidgetView, TasksWidgetView и т.д. должны быть обновлены,
// чтобы использовать @EnvironmentObject вместо передачи dataStore через init.
// Например, для MoneyWidgetView:
/*
struct MoneyWidgetView: View {
    @EnvironmentObject var dataStore: FinancialDataStore
    var body: some View {
        // Ваш код для виджета, использующий dataStore
        Text("Финансы: \(dataStore.transactions.count) транзакций")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150) // Примерный размер виджета
            .background(.thinMaterial)
            .cornerRadius(16)
    }
}
*/
