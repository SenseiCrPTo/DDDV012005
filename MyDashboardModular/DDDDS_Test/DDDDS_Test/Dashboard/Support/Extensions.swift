import UIKit

extension UIView {
    func addTapAnimation(color: UIColor) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            self.backgroundColor = color.withAlphaComponent(0.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
