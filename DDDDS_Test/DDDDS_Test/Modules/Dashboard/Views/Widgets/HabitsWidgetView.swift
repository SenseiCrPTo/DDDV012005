import UIKit

final class HabitsWidgetView: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 627.71, height: 1306.01))
        backgroundColor = UIColor(hex: "#54AFD5").withAlphaComponent(0.1)
        layer.cornerRadius = 20
        
        let titleLabel = UILabel()
        titleLabel.text = "Habits"
        titleLabel.font = UIFont.systemFont(ofSize: 55.33, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#313131")
        addSubview(titleLabel)
        // Центрирование...
    }
}
