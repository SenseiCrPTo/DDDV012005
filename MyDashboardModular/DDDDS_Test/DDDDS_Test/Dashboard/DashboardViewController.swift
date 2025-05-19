import UIKit

final class DashboardViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F5F5F5")
        setupScrollView()
        setupWidgets()
    }
    
    private func setupScrollView() {
        scrollView.isScrollEnabled = false // По вашему ТЗ
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 20
        // AutoLayout...
    }
    
    private func setupWidgets() {
        contentStack.addArrangedSubview(MoneyWidgetView())
        contentStack.addArrangedSubview(TasksWidgetView())
        contentStack.addArrangedSubview(BodyWidgetView())
        contentStack.addArrangedSubview(DiaryWidgetView())
        contentStack.addArrangedSubview(HabitsWidgetView())
    }
}
