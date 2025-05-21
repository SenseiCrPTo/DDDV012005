import UIKit

// Placeholder for Task and GoalHorizon for now
// These should be replaced with actual model imports later
struct PlaceholderTask {
    var title: String
    var isCompleted: Bool
    var isImportant: Bool
}

enum PlaceholderGoalHorizon {
    case month
}

// Actual Task model, assuming it's accessible.
// If not, we'll need to define a local placeholder or ensure it's imported.
// For now, assuming Task.swift is in a place where it can be found.
// import MyDashboardModular.Modules.Tasks.Models // This kind of import might not work directly here.

// Define the delegate protocol
protocol TasksWidgetUIViewDelegate: AnyObject {
    func didTapTasksWidget(_ tasksWidgetView: TasksWidgetUIView)
}

class TasksWidgetUIView: UIView {

    // MARK: - Delegate
    weak var delegate: TasksWidgetUIViewDelegate?

    // MARK: - DataStore
    var taskDataStore: TaskDataStore?

    // MARK: - UI Elements
    private let titleLabel = UILabel()
    private let monthlyStatsLabel = UILabel()
    private let monthlyProgressView = UIProgressView()
    private let topGoalsTitleLabel = UILabel()
    private let topGoalsStackView = UIStackView()
    private let todayTasksTitleLabel = UILabel()
    private let todayTasksStackView = UIStackView()
    private let noTasksLabel = UILabel()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupSubviews()
        setupLayout()
        setupTapGesture() // Add tap gesture
        // configureWithPlaceholderData() // Will be called from configure(with:) if no data store
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemGray6 // Similar to Material.thin
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    private func setupSubviews() {
        // Title
        titleLabel.text = "Задачи"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold) // .headline
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Monthly Stats
        monthlyStatsLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        monthlyStatsLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(monthlyStatsLabel)

        monthlyProgressView.progressViewStyle = .default
        monthlyProgressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(monthlyProgressView)

        // Top Goals
        topGoalsTitleLabel.text = "Основные цели на месяц:"
        topGoalsTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold) // .caption.bold()
        topGoalsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topGoalsTitleLabel)

        topGoalsStackView.axis = .vertical
        topGoalsStackView.spacing = 4
        topGoalsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topGoalsStackView)

        // Today's Tasks
        todayTasksTitleLabel.text = "Текущие задачи на сегодня:"
        todayTasksTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold) // .caption.bold()
        todayTasksTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(todayTasksTitleLabel)

        todayTasksStackView.axis = .vertical
        todayTasksStackView.spacing = 4
        todayTasksStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(todayTasksStackView)
        
        // No Tasks Label
        noTasksLabel.text = "Нет активных задач или целей!"
        noTasksLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        noTasksLabel.textColor = .gray
        noTasksLabel.textAlignment = .center
        noTasksLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(noTasksLabel)
    }

    private func setupLayout() {
        let padding: CGFloat = 10

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            monthlyStatsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            monthlyStatsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            monthlyStatsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            monthlyProgressView.topAnchor.constraint(equalTo: monthlyStatsLabel.bottomAnchor, constant: 4),
            monthlyProgressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            monthlyProgressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            monthlyProgressView.heightAnchor.constraint(equalToConstant: 5),


            topGoalsTitleLabel.topAnchor.constraint(equalTo: monthlyProgressView.bottomAnchor, constant: 8),
            topGoalsTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            topGoalsTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            topGoalsStackView.topAnchor.constraint(equalTo: topGoalsTitleLabel.bottomAnchor, constant: 4),
            topGoalsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            topGoalsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            todayTasksTitleLabel.topAnchor.constraint(equalTo: topGoalsStackView.bottomAnchor, constant: 8),
            todayTasksTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            todayTasksTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),

            todayTasksStackView.topAnchor.constraint(equalTo: todayTasksTitleLabel.bottomAnchor, constant: 4),
            todayTasksStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            todayTasksStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            // Ensure stack view does not push content out if it's empty or has few items
            todayTasksStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -padding),
            
            noTasksLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noTasksLabel.centerYAnchor.constraint(equalTo: centerYAnchor), // Or adjust based on where it should appear
            noTasksLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: padding),
            noTasksLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -padding)
        ])
    }

    // MARK: - Data Configuration
    func configure(with dataStore: TaskDataStore) {
        self.taskDataStore = dataStore
        updateUIFromDataStore()
    }

    private func updateUIFromDataStore() {
        guard let dataStore = taskDataStore else {
            configureWithPlaceholderData() // Fallback if no data store
            return
        }

        let monthlyStats = dataStore.monthlyTaskStatsForWidget
        monthlyStatsLabel.text = "Цели на месяц: \(monthlyStats.completed)/\(monthlyStats.total)"
        if monthlyStats.total > 0 {
            monthlyProgressView.progress = Float(monthlyStats.completed) / Float(monthlyStats.total)
            monthlyProgressView.tintColor = (monthlyStats.completed == monthlyStats.total && monthlyStats.total > 0) ? .systemGreen : .systemOrange
        } else {
            monthlyProgressView.progress = 0
            monthlyStatsLabel.text = "Нет целей на этот месяц." // As per SwiftUI version
        }
        

        let topGoals = dataStore.topMonthlyGoalsForWidget // These are [Task]
        let todayTasks = dataStore.tasksDueTodayForWidget // These are [Task]

        updateTasksList(in: topGoalsStackView, with: topGoals.map { mapTaskToPlaceholder($0) })
        updateTasksList(in: todayTasksStackView, with: todayTasks.map { mapTaskToPlaceholder($0) })
        
        let hasMonthlyGoals = monthlyStats.total > 0
        let hasTopGoals = !topGoals.isEmpty
        let hasTodayTasks = !todayTasks.isEmpty

        monthlyStatsLabel.isHidden = !hasMonthlyGoals
        monthlyProgressView.isHidden = !hasMonthlyGoals
        
        topGoalsTitleLabel.isHidden = !hasTopGoals
        topGoalsStackView.isHidden = !hasTopGoals
        
        todayTasksTitleLabel.isHidden = !hasTodayTasks
        todayTasksStackView.isHidden = !hasTodayTasks
        
        noTasksLabel.isHidden = hasMonthlyGoals || hasTopGoals || hasTodayTasks
        
        // Adjust visibility of titles based on content
        // Deactivate all conditional constraints first
        self.constraints.filter { $0.identifier == "conditionalTop_todayTasksTitleLabel" || $0.identifier == "conditionalTop_topGoalsTitleLabel" }.forEach { $0.isActive = false }

        if topGoalsStackView.isHidden && !todayTasksTitleLabel.isHidden {
            let constraint = todayTasksTitleLabel.topAnchor.constraint(equalTo: monthlyProgressView.bottomAnchor, constant: 8)
            constraint.identifier = "conditionalTop_todayTasksTitleLabel"
            constraint.isActive = true
        } else if monthlyStatsLabel.isHidden && !topGoalsTitleLabel.isHidden { // If monthly stats are hidden, top goals title moves up
            let constraint = topGoalsTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
            constraint.identifier = "conditionalTop_topGoalsTitleLabel"
            constraint.isActive = true
        }
        // Default constraints are set in setupLayout() if these conditions aren't met.
    }
    
    // Helper to map real Task to PlaceholderTask for TaskRowView
    private func mapTaskToPlaceholder(_ task: Task) -> PlaceholderTask {
        return PlaceholderTask(title: task.title, isCompleted: task.isCompleted, isImportant: task.isImportant)
    }

    func configureWithPlaceholderData() { // Renamed to be private or ensure it's a fallback
        let completedMonthly = 2
        let totalMonthly = 5
        monthlyStatsLabel.text = "Цели на месяц: \(completedMonthly)/\(totalMonthly)"
        monthlyProgressView.progress = Float(completedMonthly) / Float(totalMonthly)
        monthlyProgressView.tintColor = (completedMonthly == totalMonthly && totalMonthly > 0) ? .systemGreen : .systemOrange

        let topGoals: [PlaceholderTask] = [
            PlaceholderTask(title: "Закончить отчет по проекту X (Placeholder)", isCompleted: false, isImportant: true)
        ]

        let todayTasksPlaceholders: [PlaceholderTask] = [
            PlaceholderTask(title: "Подготовить презентацию (Placeholder)", isCompleted: false, isImportant: true),
            PlaceholderTask(title: "Встреча с командой (Placeholder)", isCompleted: false, isImportant: false)
        ]
        
        updateTasksList(in: topGoalsStackView, with: topGoals)
        updateTasksList(in: todayTasksStackView, with: todayTasksPlaceholders)
        // updateTasksList(in: topGoalsStackView, with: topGoals, horizon: .month) // Not needed with real tasks
        // updateTasksList(in: todayTasksStackView, with: todayTasks, horizon: nil) // Not needed with real tasks

        let hasMonthlyGoals = totalMonthly > 0
        let hasTopGoals = !topGoals.isEmpty
        let hasTodayTasks = !todayTasks.isEmpty

        monthlyStatsLabel.isHidden = !hasMonthlyGoals
        monthlyProgressView.isHidden = !hasMonthlyGoals
        
        topGoalsTitleLabel.isHidden = !hasTopGoals
        topGoalsStackView.isHidden = !hasTopGoals
        
        todayTasksTitleLabel.isHidden = !hasTodayTasks
        todayTasksStackView.isHidden = !hasTodayTasks
        
        noTasksLabel.isHidden = hasMonthlyGoals || hasTopGoals || hasTodayTasks
        
        // Adjust visibility of titles based on content
        // Deactivate all conditional constraints first
        self.constraints.filter { $0.identifier == "conditionalTop_todayTasksTitleLabel_placeholder" || $0.identifier == "conditionalTop_topGoalsTitleLabel_placeholder" }.forEach { $0.isActive = false }

        if !hasTopGoals && hasTodayTasks { // If no top goals but there are today tasks
            let constraint = todayTasksTitleLabel.topAnchor.constraint(equalTo: monthlyProgressView.bottomAnchor, constant: 8)
            constraint.identifier = "conditionalTop_todayTasksTitleLabel_placeholder"
            constraint.isActive = true
        } else if !hasMonthlyGoals && hasTopGoals { // If no monthly stats but there are top goals
             let constraint = topGoalsTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
            constraint.identifier = "conditionalTop_topGoalsTitleLabel_placeholder"
            constraint.isActive = true
        }
        // Default constraints are set in setupLayout() if these conditions aren't met.
    }

    private func updateTasksList(in stackView: UIStackView, with tasks: [PlaceholderTask]) { // Removed horizon
        // Clear previous tasks
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Show only top 1 for goals, top 2 for today's tasks as per original SwiftUI
        let tasksToDisplay: [PlaceholderTask]
        if stackView == topGoalsStackView {
            tasksToDisplay = Array(tasks.prefix(1))
        } else if stackView == todayTasksStackView {
            tasksToDisplay = Array(tasks.prefix(2))
        } else {
            tasksToDisplay = tasks
        }
        
        tasksToDisplay.forEach { task in
            let taskRow = TaskRowView(task: task)
            stackView.addArrangedSubview(taskRow)
        }
    }

    // MARK: - Actions
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        delegate?.didTapTasksWidget(self)
    }
}

// MARK: - TaskRowView (Helper UIView)
class TaskRowView: UIView {
    let task: PlaceholderTask

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let starImageView = UIImageView()

    init(task: PlaceholderTask) {
        self.task = task
        super.init(frame: .zero)
        setupViews()
        setupLayout()
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        titleLabel.font = UIFont.systemFont(ofSize: 12) // .caption
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = .systemYellow
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(starImageView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18), // Increased size
            iconImageView.heightAnchor.constraint(equalToConstant: 18), // Increased size

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: starImageView.leadingAnchor, constant: -6),

            starImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            starImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 12), // Approximate size
            starImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
         titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func configureView() {
        let iconName = task.isCompleted ? "checkmark.circle.fill" : "circle"
        let iconColor: UIColor = task.isCompleted ? .systemGreen : (task.isImportant ? .systemOrange : .secondaryLabel)
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor

        titleLabel.text = task.title
        if task.isCompleted {
            titleLabel.textColor = .gray
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: task.title)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            titleLabel.attributedText = attributeString
        } else {
            titleLabel.textColor = .label
        }
        
        starImageView.isHidden = !task.isImportant || task.isCompleted
    }
}
