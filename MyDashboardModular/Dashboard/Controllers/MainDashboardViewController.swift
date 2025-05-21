import UIKit
import SwiftUI // TODO: Remove this dependency once DataStores are UI-framework-agnostic

// Assuming DetailViewControllers are accessible
// Modules/Tasks/Controllers/TasksDetailViewController.swift
// Modules/Finances/Controllers/MoneyDetailViewController.swift
// Modules/Body/Controllers/BodyDetailViewController.swift
// Modules/Diary/Controllers/DiaryDetailViewController.swift
// Modules/Habits/Controllers/HabitDetailViewController.swift

class MainDashboardViewController: UIViewController,
                                   TasksWidgetUIViewDelegate,
                                   MoneyWidgetUIViewDelegate,
                                   BodyWidgetUIViewDelegate,
                                   DiaryWidgetUIViewDelegate,
                                   HabitWidgetUIViewDelegate {

    // MARK: - Data Stores
    private var habitDataStore: HabitDataStore!
    private var diaryDataStore: DiaryDataStore!
    private var taskDataStore: TaskDataStore!
    private var financialDataStore: FinancialDataStore!
    private var bodyDataStore: BodyDataStore!

    // MARK: - UI Properties
    private var habitWidget: HabitWidgetUIView! 
    private var mainStackView: UIStackView! 
    
    var headerView: UIView! 
    var titleLabel: UILabel!
    var collectionView: UICollectionView!
    
    private let widgetPlaceholders = 5

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        instantiateDataStores()
        setupMainStackView()
        setupHeaderView() 
        setupCollectionView()
        setupHabitWidgetView()
        setupLayoutConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Data Store Initialization
    private func instantiateDataStores() {
        habitDataStore = HabitDataStore()
        diaryDataStore = DiaryDataStore()
        taskDataStore = TaskDataStore()
        financialDataStore = FinancialDataStore()
        bodyDataStore = BodyDataStore()
    }

    // MARK: - Setup UI
    private func setupMainStackView() {
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        // Default spacing for the stack view. Custom spacing will be applied after specific elements.
        // The original VStack spacing was 16. Let's set this as a general default.
        mainStackView.spacing = 16 
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
    }
    
    private func setupHeaderView() {
        headerView = UIView()
        titleLabel = UILabel()
        titleLabel.text = "DayDash"
        titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        mainStackView.addArrangedSubview(headerView)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(150)) 
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "widgetHostCell")
        mainStackView.addArrangedSubview(collectionView)
    }

    private func setupHabitWidgetView() {
        habitWidget = HabitWidgetUIView()
        habitWidget.configure(with: habitDataStore) // Configure before setting delegate
        habitWidget.delegate = self // Set delegate
        mainStackView.addArrangedSubview(habitWidget)
    }

    // MARK: - Layout Constraints
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8), 
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8), 
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            collectionView.heightAnchor.constraint(equalToConstant: (150 * 2) + 8 + 8 + 8 + 8), 
        ])
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension MainDashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return widgetPlaceholders
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "widgetHostCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear 
        cell.layer.cornerRadius = 0 
        var widgetView: UIView?

        switch indexPath.item {
        case 0:
            let tasksWidget = TasksWidgetUIView()
            tasksWidget.configure(with: taskDataStore)
            tasksWidget.delegate = self 
            widgetView = tasksWidget
        case 1:
            let moneyWidget = MoneyWidgetUIView()
            moneyWidget.configure(with: financialDataStore)
            moneyWidget.delegate = self 
            widgetView = moneyWidget
        case 2:
            let bodyWidget = BodyWidgetUIView()
            bodyWidget.configure(with: bodyDataStore)
            bodyWidget.delegate = self 
            widgetView = bodyWidget
        case 3:
            let diaryWidget = DiaryWidgetUIView()
            diaryWidget.configure(with: diaryDataStore)
            diaryWidget.delegate = self 
            widgetView = diaryWidget
        default:
            let placeholderView = UIView()
            placeholderView.backgroundColor = UIColor(hue: CGFloat(indexPath.item) / CGFloat(widgetPlaceholders), saturation: 1, brightness: 1, alpha: 1)
            placeholderView.layer.cornerRadius = 10
            widgetView = placeholderView
        }
        
        if let widget = widgetView {
            widget.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(widget)
            NSLayoutConstraint.activate([
                widget.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                widget.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                widget.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                widget.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])
            if !(widget is TasksWidgetUIView || widget is MoneyWidgetUIView || widget is BodyWidgetUIView || widget is DiaryWidgetUIView) {
                 widget.backgroundColor = UIColor(hue: CGFloat(indexPath.item) / CGFloat(widgetPlaceholders), saturation: 1, brightness: 1, alpha: 1)
                 widget.layer.cornerRadius = 10
            }
        }
        
        return cell
    }
}

// MARK: - Widget Delegate Implementations
extension MainDashboardViewController {
    func didTapTasksWidget(_ tasksWidgetView: TasksWidgetUIView) {
        let tasksDetailVC = TasksDetailViewController()
        // tasksDetailVC.taskDataStore = self.taskDataStore // Optional: Pass data
        self.navigationController?.pushViewController(tasksDetailVC, animated: true)
    }

    func didTapMoneyWidget(_ moneyWidgetView: MoneyWidgetUIView) {
        let moneyDetailVC = MoneyDetailViewController()
        // moneyDetailVC.financialDataStore = self.financialDataStore // Optional: Pass data
        self.navigationController?.pushViewController(moneyDetailVC, animated: true)
    }

    func didTapBodyWidget(_ bodyWidgetView: BodyWidgetUIView) {
        let bodyDetailVC = BodyDetailViewController()
        // bodyDetailVC.bodyDataStore = self.bodyDataStore // Optional: Pass data
        self.navigationController?.pushViewController(bodyDetailVC, animated: true)
    }

    func didTapDiaryWidget(_ diaryWidgetView: DiaryWidgetUIView) {
        let diaryDetailVC = DiaryDetailViewController()
        // diaryDetailVC.diaryDataStore = self.diaryDataStore // Optional: Pass data
        self.navigationController?.pushViewController(diaryDetailVC, animated: true)
    }

    func didTapHabitWidget(_ habitWidgetView: HabitWidgetUIView) {
        let habitDetailVC = HabitDetailViewController()
        // habitDetailVC.habitDataStore = self.habitDataStore // Optional: Pass data
        self.navigationController?.pushViewController(habitDetailVC, animated: true)
    }
}
