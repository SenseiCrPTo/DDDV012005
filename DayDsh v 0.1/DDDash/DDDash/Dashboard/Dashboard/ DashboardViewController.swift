import UIKit
import SwiftUI

class DashboardViewController: UIViewController {
    private let viewModel = DashboardViewModel()
    private var coordinator: DashboardCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundMain")
        coordinator = DashboardCoordinator(viewController: self)
        setupSwiftUI()
    }
    
    private func setupSwiftUI() {
        let swiftUIView = DashboardContainerView(viewModel: viewModel, coordinator: coordinator!)
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
