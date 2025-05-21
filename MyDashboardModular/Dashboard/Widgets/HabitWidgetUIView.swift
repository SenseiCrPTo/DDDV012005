import UIKit
// Assuming HabitDataStore.swift is accessible

protocol HabitWidgetUIViewDelegate: AnyObject {
    func didTapHabitWidget(_ habitWidgetView: HabitWidgetUIView)
}

// Placeholder for Habit model
struct PlaceholderHabit {
    let id: UUID = UUID()
    var name: String
    var iconName: String
    var color: UIColor
    var isCompletedToday: Bool = false
    var isDueToday: Bool = true
    var isArchived: Bool = false
}

class HabitWidgetUIView: UIView {

    // MARK: - Delegate
    weak var delegate: HabitWidgetUIViewDelegate?

    // MARK: - DataStore
    var habitDataStore: HabitDataStore?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let summaryStackView = UIStackView()
    private let activeHabitsCountLabel = UILabel()
    private let completionPercentageLabel = UILabel()
    private let habitsGridStackView = UIStackView() // Main stack for rows of habits
    private let noHabitsLabel = UILabel()
    
    private let mainVerticalStackView = UIStackView()

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

    private func setupSubviews() {
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 12
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainVerticalStackView)

        // Title
        titleLabel.text = "Привычки"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold) // .headline
        mainVerticalStackView.addArrangedSubview(titleLabel)
        mainVerticalStackView.setCustomSpacing(4, after: titleLabel)


        // Summary Section
        summaryStackView.axis = .horizontal
        summaryStackView.distribution = .fillEqually
        summaryStackView.spacing = 8

        let activeHabitsVStack = UIStackView(arrangedSubviews: [
            createSummaryLabel(text: "Всего активных:", font: .systemFont(ofSize: 12, weight: .regular), color: .secondaryLabel),
            activeHabitsCountLabel
        ])
        activeHabitsVStack.axis = .vertical
        activeHabitsVStack.alignment = .leading
        
        activeHabitsCountLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold) // Adjusted to match .title3

        let completionVStack = UIStackView(arrangedSubviews: [
            createSummaryLabel(text: "Выполнено сегодня:", font: .systemFont(ofSize: 12, weight: .regular), color: .secondaryLabel),
            completionPercentageLabel
        ])
        completionVStack.axis = .vertical
        completionVStack.alignment = .leading
        
        completionPercentageLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold) // Adjusted to match .title3

        summaryStackView.addArrangedSubview(activeHabitsVStack)
        summaryStackView.addArrangedSubview(completionVStack)
        mainVerticalStackView.addArrangedSubview(summaryStackView)
        mainVerticalStackView.setCustomSpacing(8, after: summaryStackView)

        // Habits Grid
        habitsGridStackView.axis = .vertical
        habitsGridStackView.spacing = 10
        habitsGridStackView.alignment = .fill
        habitsGridStackView.distribution = .fillEqually
        mainVerticalStackView.addArrangedSubview(habitsGridStackView)

        // No Habits Label
        noHabitsLabel.text = "Нет привычек для отображения на виджете."
        noHabitsLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        noHabitsLabel.textColor = .gray
        noHabitsLabel.textAlignment = .center
        noHabitsLabel.numberOfLines = 0
        noHabitsLabel.isHidden = true // Initially hidden
        mainVerticalStackView.addArrangedSubview(noHabitsLabel)
        
        // Add spacer to push content to top if habits grid is empty or has few items
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        mainVerticalStackView.addArrangedSubview(spacer)
    }
    
    private func createSummaryLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        return label
    }

    private func setupLayout() {
        let padding: CGFloat = 12
        NSLayoutConstraint.activate([
            mainVerticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
            noHabitsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60) // Min height for noHabitsLabel
        ])
    }

    // MARK: - Data Configuration
    func configure(with dataStore: HabitDataStore) {
        self.habitDataStore = dataStore
        updateUIFromDataStore()
    }

    private func updateUIFromDataStore() {
        guard let dataStore = habitDataStore else {
            configureWithPlaceholderData() // Fallback
            return
        }

        activeHabitsCountLabel.text = "\(dataStore.habits.filter { !$0.isArchived }.count)"
        
        let percentage = dataStore.dailyCompletionPercentage()
        completionPercentageLabel.text = String(format: "%.0f%%", percentage)
        if percentage >= 75 { completionPercentageLabel.textColor = .systemGreen }
        else if percentage >= 40 { completionPercentageLabel.textColor = .systemOrange }
        else { completionPercentageLabel.textColor = .systemRed }

        let habitsToDisplay = dataStore.habitsForWidget // This is already a [Habit]
        
        if habitsToDisplay.isEmpty {
            noHabitsLabel.isHidden = false
            habitsGridStackView.isHidden = true
            summaryStackView.isHidden = true 
            titleLabel.text = "Привычки" // Keep original title even if empty
        } else {
            noHabitsLabel.isHidden = true
            habitsGridStackView.isHidden = false
            summaryStackView.isHidden = false
            // Map real Habit to PlaceholderHabit for the item view, or adapt item view
            updateHabitsGrid(with: habitsToDisplay.map { mapRealHabitToPlaceholder($0, dataStore: dataStore) })
        }
    }
    
    // Helper to map real Habit to PlaceholderHabit for createHabitItemView
    private func mapRealHabitToPlaceholder(_ habit: Habit, dataStore: HabitDataStore) -> PlaceholderHabit {
        return PlaceholderHabit(
            id: habit.id, // Keep ID if needed for interaction
            name: habit.name,
            iconName: habit.iconName,
            color: habit.uiColor, // Assuming Habit model has a uiColor property or similar
            isCompletedToday: dataStore.isHabitCompletedOn(habitID: habit.id, date: Date()),
            isDueToday: dataStore.isHabitDueOn(habit: habit, date: Date()),
            isArchived: habit.isArchived
        )
    }

    func configureWithPlaceholderData() {
        activeHabitsCountLabel.text = "0" 
        
        let percentage = 60.0
        completionPercentageLabel.text = String(format: "%.0f%%", percentage)
        if percentage >= 75 { completionPercentageLabel.textColor = .systemGreen }
        else if percentage >= 40 { completionPercentageLabel.textColor = .systemOrange }
        else { completionPercentageLabel.textColor = .systemRed }

        let habits: [PlaceholderHabit] = [
            PlaceholderHabit(name: "Утренняя зарядка", iconName: "figure.walk", color: .systemBlue, isCompletedToday: true),
            PlaceholderHabit(name: "Читать 30 минут", iconName: "book.fill", color: .systemOrange),
            PlaceholderHabit(name: "Медитация", iconName: "heart.fill", color: .systemPurple, isArchived: false),
            PlaceholderHabit(name: "Пить воду 2л", iconName: "drop.fill", color: .systemTeal, isCompletedToday: true, isDueToday: false)
        ]
        
        let habitsToDisplay = Array(habits.prefix(4))

        if habitsToDisplay.isEmpty {
            noHabitsLabel.isHidden = false
            habitsGridStackView.isHidden = true
            summaryStackView.isHidden = true // Also hide summary if no habits
            titleLabel.text = "Привычки (нет данных)"
        } else {
            noHabitsLabel.isHidden = true
            habitsGridStackView.isHidden = false
            summaryStackView.isHidden = false
            updateHabitsGrid(with: habitsToDisplay)
        }
        
        // Ensure overall widget has a minimum height
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 180).isActive = true
    }

    private func updateHabitsGrid(with placeholderHabits: [PlaceholderHabit]) {
        habitsGridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear old views

        let itemsPerRow = 2
        for i in 0..<placeholderHabits.count {
            if i % itemsPerRow == 0 { // Start a new row
                let rowStackView = UIStackView()
                rowStackView.axis = .horizontal
                rowStackView.spacing = 10
                rowStackView.distribution = .fillEqually
                habitsGridStackView.addArrangedSubview(rowStackView)
            }
            
            if let currentRowStackView = habitsGridStackView.arrangedSubviews.last as? UIStackView {
                let habitItemView = createHabitItemView(habit: placeholderHabits[i])
                currentRowStackView.addArrangedSubview(habitItemView)
            }
        }
        
        // If the last row has only one item, add a spacer to keep alignment
        if let lastRow = habitsGridStackView.arrangedSubviews.last as? UIStackView, lastRow.arrangedSubviews.count == 1 {
            let spacerView = UIView()
            lastRow.addArrangedSubview(spacerView)
        }
    }

    private func createHabitItemView(habit: PlaceholderHabit) -> UIView {
        let button = UIButton(type: .custom) // Using UIButton to mimic interactivity
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: habit.iconName)
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20)) // Adjusted symbol size
        iconImageView.tintColor = (habit.isCompletedToday && habit.isDueToday) ? .white : habit.color
        iconImageView.contentMode = .center
        iconImageView.backgroundColor = (habit.isCompletedToday && habit.isDueToday) ? habit.color : habit.color.withAlphaComponent(0.2)
        iconImageView.layer.cornerRadius = 18 // width/2 for 36x36
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = habit.name
        nameLabel.font = UIFont.systemFont(ofSize: 10) // .caption2
        nameLabel.numberOfLines = 2
        nameLabel.textAlignment = .center
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let itemStackView = UIStackView(arrangedSubviews: [iconImageView, nameLabel])
        itemStackView.axis = .vertical
        itemStackView.alignment = .center
        itemStackView.spacing = 6
        itemStackView.isUserInteractionEnabled = false // Button handles interaction
        itemStackView.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(itemStackView)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.opacity = (habit.isDueToday && !habit.isArchived) ? 1.0 : (habit.isArchived ? 0.4 : 0.6)
        button.isEnabled = (habit.isDueToday && !habit.isArchived)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 30), // Adjusted height
            
            itemStackView.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            itemStackView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -8),
            itemStackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            itemStackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
        ])
        // Add target for button action if needed: button.addTarget(self, action: #selector(habitItemTapped(_:)), for: .touchUpInside)
        return button
    }
}

// MARK: - Actions
extension HabitWidgetUIView {
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        // Note: Individual habit items inside might need their own tap handling
        // if the entire widget shouldn't navigate. For this task, the whole widget is tappable.
    }

    @objc private func handleTap() {
        delegate?.didTapHabitWidget(self)
    }
}
