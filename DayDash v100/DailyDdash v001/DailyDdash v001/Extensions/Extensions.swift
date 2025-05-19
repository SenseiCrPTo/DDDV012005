// Extensions.swift
import UIKit

extension UIView {
    func addWidgetInteractionAnimation(accentColor: UIColor) {
        let originalColor = self.backgroundColor
        
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.backgroundColor = accentColor.withAlphaComponent(0.15)
        }) { _ in
            UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseOut) {
                self.transform = .identity
                self.backgroundColor = originalColor
            }
        }
    }
}
