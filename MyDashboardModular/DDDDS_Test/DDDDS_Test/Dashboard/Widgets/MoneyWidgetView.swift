import UIKit

final class MoneyWidgetView: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 643.95, height: 894.96))
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 20
        
        let titleLabel = UILabel()
        titleLabel.text = "Money"
        titleLabel.font = UIFont.systemFont(ofSize: 55.33, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#313131")
        addSubview(titleLabel)
        // Центрирование...
    }
}
