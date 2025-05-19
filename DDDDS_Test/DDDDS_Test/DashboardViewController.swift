import UIKit
import SwiftUI

class DashboardViewController: UIViewController {
    
    private let widgetsGrid = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupWidgets()
    }
    
    private func setupMainView() {
        view.backgroundColor = .backgroundBase
        view.addSubview(widgetsGrid)
        // Настройка constraints для grid
    }
    
    private func addWidget<T: View>(_ view: T, size: CGSize) {
        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .clear
        widgetsGrid.addArrangedSubview(host.view)
    }
    
    private func setupWidgets() {
        let screenSize = UIScreen.main.bounds.size
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let widgetSizes = [
            CGSize(width: isPad ? 643 : screenSize.width * 0.9,
                   height: isPad ? 894 : screenSize.height * 0.4),
            // ... остальные размеры
        ]
        
        addWidget(MoneyWidget(size: widgetSizes[0]), size: widgetSizes[0])
        // Добавьте остальные виджеты
    }
}
