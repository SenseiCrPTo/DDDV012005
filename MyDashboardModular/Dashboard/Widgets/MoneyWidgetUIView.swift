import UIKit
// Assuming FinancialDataStore.swift is accessible
// import MyDashboardModular.Modules.Finances.DataStore

protocol MoneyWidgetUIViewDelegate: AnyObject {
    func didTapMoneyWidget(_ moneyWidgetView: MoneyWidgetUIView)
}

class MoneyWidgetUIView: UIView {

    // MARK: - Delegate
    weak var delegate: MoneyWidgetUIViewDelegate?

    // MARK: - DataStore
    var financialDataStore: FinancialDataStore?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let periodSegmentedControl = UISegmentedControl(items: ["Нед", "Мес", "Год", "Все"])
    private let chartPlaceholderView = UIView() // Placeholder for chart
    private let noDataLabel = UILabel()

    private let incomeLabel = UILabel()
    private let expensesLabel = UILabel()
    private let savingsLabel = UILabel()
    private let balanceLabel = UILabel()
    
    private let mainStackView = UIStackView()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubviews()
        setupLayout()
        setupTapGesture()
        configureWithPlaceholderData() // Still using placeholder for now
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    private func createMetricLabel(text: String, value: String, valueColor: UIColor = .label) -> UILabel {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: value, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold), NSAttributedString.Key.foregroundColor: valueColor]))
        label.attributedText = attributedText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupSubviews() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 4 // Matched SwiftUI VStack spacing
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)

        // Title and Segmented Control
        let headerStackView = UIStackView()
        headerStackView.axis = .horizontal
        headerStackView.spacing = 8
        headerStackView.alignment = .center
        
        titleLabel.text = "Финансы"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold) // .headline, .rounded not directly available
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        headerStackView.addArrangedSubview(titleLabel)

        periodSegmentedControl.selectedSegmentIndex = 0
        periodSegmentedControl.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        // Make segmented control smaller
        periodSegmentedControl.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        headerStackView.addArrangedSubview(periodSegmentedControl)
        mainStackView.addArrangedSubview(headerStackView)

        // Chart Placeholder
        chartPlaceholderView.backgroundColor = .systemGray4
        chartPlaceholderView.layer.cornerRadius = 8
        let chartInfoLabel = UILabel()
        chartInfoLabel.text = "[Chart Placeholder]"
        chartInfoLabel.font = UIFont.systemFont(ofSize: 14)
        chartInfoLabel.textColor = .systemGray
        chartInfoLabel.textAlignment = .center
        chartInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        chartPlaceholderView.addSubview(chartInfoLabel)
        
        NSLayoutConstraint.activate([
            chartInfoLabel.centerXAnchor.constraint(equalTo: chartPlaceholderView.centerXAnchor),
            chartInfoLabel.centerYAnchor.constraint(equalTo: chartPlaceholderView.centerYAnchor),
            chartPlaceholderView.heightAnchor.constraint(equalToConstant: 100)
        ])
        mainStackView.addArrangedSubview(chartPlaceholderView)

        // No Data Label
        noDataLabel.text = "Нет данных за выбранный период."
        noDataLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.isHidden = true // Initially hidden
        mainStackView.addArrangedSubview(noDataLabel)
        
        // Metrics
        incomeLabel.attributedText = createMetricLabel(text: "Доход (Нед): ", value: "15,000 ₽").attributedText
        expensesLabel.attributedText = createMetricLabel(text: "Расход (Нед): ", value: "5,000 ₽", valueColor: .systemRed).attributedText
        savingsLabel.attributedText = createMetricLabel(text: "Накопления (Нед): ", value: "10,000 ₽", valueColor: .systemBlue).attributedText
        balanceLabel.attributedText = createMetricLabel(text: "Общий баланс: ", value: "150,000 ₽").attributedText

        mainStackView.addArrangedSubview(incomeLabel)
        mainStackView.addArrangedSubview(expensesLabel)
        mainStackView.addArrangedSubview(savingsLabel)
        mainStackView.addArrangedSubview(balanceLabel)
    }

    private func setupLayout() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -padding)
        ])
    }

    // MARK: - Data Configuration
    func configure(with dataStore: FinancialDataStore) {
        self.financialDataStore = dataStore
        // Add target for segmented control value change
        periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        updateUIFromDataStore()
    }
    
    @objc private func periodChanged() {
        guard let dataStore = financialDataStore else { return }
        let selectedIndex = periodSegmentedControl.selectedSegmentIndex
        if let period = TimePeriodSelection.allCases[safe: selectedIndex] {
            dataStore.selectedAnalyticsPeriod = period // This should trigger @Published update in DataStore
            // We need a way for DataStore changes to reflect back here.
            // For now, explicitly call updateUI. Ideally, use Combine or delegation.
            updateUIFromDataStore()
        }
    }

    private func updateUIFromDataStore() {
        guard let dataStore = financialDataStore else {
            configureWithPlaceholderData() // Fallback
            return
        }

        // Update segmented control from dataStore's selected period
        if let index = TimePeriodSelection.allCases.firstIndex(of: dataStore.selectedAnalyticsPeriod) {
            periodSegmentedControl.selectedSegmentIndex = index
        }

        let chartData = dataStore.periodicalChartData
        let hasData = !chartData.filter({ $0.value > 0 }).isEmpty || dataStore.selectedAnalyticsPeriod == .allTime
        
        chartPlaceholderView.isHidden = !hasData
        noDataLabel.isHidden = hasData

        let periodShortLabel = dataStore.selectedAnalyticsPeriod.shortLabel
        incomeLabel.attributedText = createMetricLabel(text: "Доход (\(periodShortLabel)): ", value: dataStore.incomeForSelectedPeriodString).attributedText
        expensesLabel.attributedText = createMetricLabel(text: "Расход (\(periodShortLabel)): ", value: dataStore.expensesForSelectedPeriodString, valueColor: .systemRed).attributedText
        savingsLabel.attributedText = createMetricLabel(text: "Накопления (\(periodShortLabel)): ", value: dataStore.savingsForSelectedPeriodString, valueColor: .systemBlue).attributedText
        balanceLabel.attributedText = createMetricLabel(text: "Общий баланс: ", value: dataStore.totalBalanceString).attributedText
    }
    
    func configureWithPlaceholderData() {
        // This can be a fallback or initial state before dataStore is set
        periodSegmentedControl.selectedSegmentIndex = 0 // Default to 'Month' or first item
        let selectedPeriod = periodSegmentedControl.titleForSegment(at: periodSegmentedControl.selectedSegmentIndex) ?? "Нед"

        chartPlaceholderView.isHidden = false
        noDataLabel.isHidden = true
        
        incomeLabel.attributedText = createMetricLabel(text: "Доход (\(selectedPeriod)): ", value: "0 ₽").attributedText
        expensesLabel.attributedText = createMetricLabel(text: "Расход (\(selectedPeriod)): ", value: "0 ₽", valueColor: .systemRed).attributedText
        savingsLabel.attributedText = createMetricLabel(text: "Накопления (\(selectedPeriod)): ", value: "0 ₽", valueColor: .systemBlue).attributedText
        balanceLabel.attributedText = createMetricLabel(text: "Общий баланс: ", value: "0 ₽").attributedText
    }
}

// Helper extension for safe array access
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Actions
extension MoneyWidgetUIView {
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        delegate?.didTapMoneyWidget(self)
    }
}
