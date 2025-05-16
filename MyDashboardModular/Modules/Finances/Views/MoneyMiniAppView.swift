import SwiftUI
import Charts // Нужен для ClearChartView

// Предполагается, что TransactionSheetContext, TimePeriodSelection, MonthlyDataPoint, TransactionType
// и ClearChartView, AccountsView, CategoriesView, AddTransactionView определены и доступны.
// MetricRow будет использоваться из Shared/Views.

struct MoneyMiniAppView: View {
    @EnvironmentObject var dataStore: FinancialDataStore // <--- ИЗМЕНЕНО
    @State private var sheetContext: TransactionSheetContext? = nil

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencySymbol = "₽"; formatter.maximumFractionDigits = 2; formatter.minimumFractionDigits = 2; return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack { Spacer(); VStack { Text("ОБЩИЙ БАЛАНС").font(.caption).foregroundColor(.gray); Text(dataStore.totalBalanceString).font(.largeTitle.bold())}; Spacer() }.padding()
                Grid { GridRow {
                    actionButton(label: "Доход", systemImage: "arrow.up.circle.fill", color: .green, action: { self.sheetContext = TransactionSheetContext(type: .income) })
                    actionButton(label: "Расход", systemImage: "arrow.down.circle.fill", color: .red, action: { self.sheetContext = TransactionSheetContext(type: .expense) })
                    actionButton(label: "Накопить", systemImage: "arrow.down.to.line.compact", color: .blue, action: { self.sheetContext = TransactionSheetContext(type: .expense, category: dataStore.savingCategory) })
                }}.padding(.horizontal).padding(.bottom)
                Divider().padding(.horizontal)
                VStack(alignment: .leading, spacing: 4) {
                    HStack { Text("Аналитика").font(.title2.bold()); Spacer(); Picker("Период", selection: $dataStore.selectedAnalyticsPeriod) { ForEach(TimePeriodSelection.allCases) { period in Text(period.shortLabel).tag(period) } }.pickerStyle(.menu) }.padding(.horizontal)
                    Group {
                        if dataStore.periodicalChartData.filter({ $0.value > 0 }).isEmpty && dataStore.selectedAnalyticsPeriod != .allTime {
                            Text("Нет данных за выбранный период.").font(.caption).foregroundColor(.gray).frame(height: 150, alignment: .center).frame(maxWidth: .infinity).padding(.horizontal)
                        } else {
                            let xAxisLabel: String = {
                                switch dataStore.selectedAnalyticsPeriod {
                                case .week, .month: return "День"
                                case .year, .allTime: return "Месяц"
                                // Добавь default или убедись, что все кейсы TimePeriodSelection покрыты
                                }
                            }()
                            ClearChartView(data: dataStore.periodicalChartData, xAxisLabel: xAxisLabel) // ClearChartView не должен требовать DataStore
                                .padding(.horizontal).padding(.bottom, 2).frame(height: 150) // Явно задаем высоту для графика
                        }
                    }
                    VStack(spacing: 4) {
                        MetricRow(label: "Доход (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.incomeForSelectedPeriodString)
                        MetricRow(label: "Расход (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.expensesForSelectedPeriodString, valueColor: .red)
                        MetricRow(label: "Накопления (\(dataStore.selectedAnalyticsPeriod.shortLabel)):", value: dataStore.savingsForSelectedPeriodString, valueColor: .blue)
                    }.padding(.horizontal)
                }.padding(.vertical)
                Text("Последние транзакции").font(.title2.bold()).padding([.top, .leading])
                List {
                    ForEach(dataStore.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        HStack {
                            VStack(alignment: .leading) { Text(transaction.description).fontWeight(.medium); HStack(spacing: 4) { Text(transaction.category); Text("•"); Text(transaction.account) }.font(.caption).foregroundColor(.gray) }; Spacer()
                            Text(currencyFormatter.string(from: NSNumber(value: transaction.amount)) ?? "").fontWeight(.semibold).foregroundColor(transaction.type == .income ? .green : (transaction.amount == 0 ? .gray : .primary))
                        }
                        .padding(.vertical, 4).contentShape(Rectangle())
                        .onTapGesture { self.sheetContext = TransactionSheetContext(transactionToEdit: transaction) }
                    }
                    .onDelete(perform: deleteTransactionsInList)
                }
                .listStyle(PlainListStyle()).frame(minHeight: 200, idealHeight: 300 ,maxHeight: .infinity) // Уточнил frame
            }
        }
        .navigationTitle("Деньги")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // AccountsView и CategoriesView должны быть обновлены для @EnvironmentObject
                NavigationLink(destination: AccountsView()) { Image(systemName: "creditcard.fill") }
                NavigationLink(destination: CategoriesView()) { Image(systemName: "tag.fill") }
            }
        }
        .sheet(item: $sheetContext) { context in
            // AddTransactionView должен использовать @EnvironmentObject
            AddTransactionView(
                // Убери dataStore из init AddTransactionView
                transactionToEdit: context.transactionToEdit,
                initialType: context.type,
                initialCategory: context.transactionToEdit?.category ?? context.category,
                onSave: { savedTransaction in
                    if context.transactionToEdit != nil { dataStore.updateTransaction(savedTransaction) } else { dataStore.addTransaction(savedTransaction) }
                }
            )
        }
    }

    func actionButton(label: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View { /* Твой код */ Button(action: action) { VStack { Image(systemName: systemImage).font(.title2); Text(label) }.font(.headline).padding(.vertical, 10).padding(.horizontal, 5).frame(maxWidth: .infinity).background(color.opacity(0.15)).foregroundColor(color).cornerRadius(10) } }
    func deleteTransactionsInList(at offsets: IndexSet) {
        let sortedTransactions = dataStore.transactions.sorted { $0.date > $1.date }
        offsets.forEach { index in dataStore.deleteTransaction(transactionId: sortedTransactions[index].id) }
    }
}

struct MoneyMiniAppView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoneyMiniAppView()
                .environmentObject(FinancialDataStore.preview) // Убедись, что FinancialDataStore.preview существует
        }
    }
}
