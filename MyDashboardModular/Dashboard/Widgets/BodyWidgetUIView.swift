import UIKit
// Assuming BodyDataStore.swift is accessible

protocol BodyWidgetUIViewDelegate: AnyObject {
    func didTapBodyWidget(_ bodyWidgetView: BodyWidgetUIView)
}

class BodyWidgetUIView: UIView {

    // MARK: - Delegate
    weak var delegate: BodyWidgetUIViewDelegate?

    // MARK: - DataStore
    var bodyDataStore: BodyDataStore?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let weightLabel = UILabel()
    private let totalTrainingDaysLabel = UILabel()
    private let weeklyTargetLabel = UILabel()
    private let trainingProgressTitleLabel = UILabel()
    private let trainingProgressBar = UIProgressView()
    private let trainingProgressDetailLabel = UILabel()
    
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

        titleLabel.text = "Тело"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold) // .headline
        mainStackView.addArrangedSubview(titleLabel)

        weightLabel.attributedText = createMetricLabel(text: "Вес: ", value: "70.5 кг").attributedText
        mainStackView.addArrangedSubview(weightLabel)

        totalTrainingDaysLabel.attributedText = createMetricLabel(text: "Дней тренировок (всего): ", value: "120").attributedText
        mainStackView.addArrangedSubview(totalTrainingDaysLabel)
        
        weeklyTargetLabel.attributedText = createMetricLabel(text: "Цель (нед.): ", value: "3 дн.").attributedText
        mainStackView.addArrangedSubview(weeklyTargetLabel)

        trainingProgressTitleLabel.text = "Тренировки (нед.):"
        trainingProgressTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold) // .caption.bold()
        mainStackView.addArrangedSubview(trainingProgressTitleLabel)
        mainStackView.setCustomSpacing(2, after: trainingProgressTitleLabel)


        trainingProgressBar.progressViewStyle = .default
        trainingProgressBar.tintColor = .systemIndigo
        mainStackView.addArrangedSubview(trainingProgressBar)
        mainStackView.setCustomSpacing(2, after: trainingProgressBar)


        trainingProgressDetailLabel.font = UIFont.systemFont(ofSize: 10) // .caption2
        trainingProgressDetailLabel.textColor = .gray
        mainStackView.addArrangedSubview(trainingProgressDetailLabel)
        
        // Spacer to push content to top
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        mainStackView.addArrangedSubview(spacerView)
    }

    private func setupLayout() {
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
            trainingProgressBar.heightAnchor.constraint(equalToConstant: 8) // HabitTrackerBar typical height
        ])
    }

    // MARK: - Data Configuration
    func configure(with dataStore: BodyDataStore) {
        self.bodyDataStore = dataStore
        updateUIFromDataStore()
    }

    private func updateUIFromDataStore() {
        guard let dataStore = bodyDataStore else {
            configureWithPlaceholderData() // Fallback
            return
        }

        weightLabel.attributedText = createMetricLabel(text: "Вес: ", value: dataStore.currentWeightString).attributedText
        totalTrainingDaysLabel.attributedText = createMetricLabel(text: "Дней тренировок (всего): ", value: "\(dataStore.totalTrainingDays)").attributedText
        weeklyTargetLabel.attributedText = createMetricLabel(text: "Цель (нед.): ", value: "\(dataStore.targetWorkoutsPerWeek) дн.").attributedText
        
        let workoutsThisWeek = dataStore.workoutsThisWeekCount
        // The progress bar in SwiftUI was based on 7 total days for the week visual.
        // If targetWorkoutsPerWeek is the goal, the progress should be relative to that,
        // but the visual bar in original was 7 days. Let's stick to 7 days for the bar for now.
        let totalDaysInWeekForBar = 7
        trainingProgressBar.progress = Float(workoutsThisWeek) / Float(totalDaysInWeekForBar)
        
        let targetText = dataStore.targetWorkoutsPerWeek > 0 ? String(dataStore.targetWorkoutsPerWeek) : "~"
        trainingProgressDetailLabel.text = "\(workoutsThisWeek) из \(targetText) (цель)"
    }

    func configureWithPlaceholderData() {
        weightLabel.attributedText = createMetricLabel(text: "Вес: ", value: "-- кг").attributedText
        totalTrainingDaysLabel.attributedText = createMetricLabel(text: "Дней тренировок (всего): ", value: "0").attributedText
        weeklyTargetLabel.attributedText = createMetricLabel(text: "Цель (нед.): ", value: "0 дн.").attributedText

        trainingProgressBar.progress = 0
        trainingProgressDetailLabel.text = "0 из ~ (цель)"
    }
}

// MARK: - Actions
extension BodyWidgetUIView {
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        delegate?.didTapBodyWidget(self)
    }
}
