import UIKit

final class DashboardCoordinator {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showMoney() {
        let vc = MoneyViewController()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func showTodo() {
        let vc = TodoViewController()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func showBody() {
        let vc = BodyViewController()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func showSecondBrain() {
        let vc = SecondBrainViewController()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func showHabit() {
        let vc = HabitViewController()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
