//
//  UIView+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

extension UIView {
    class var identifier: String {
        return String(describing: self)
    }
    
    func makeCornerRounded(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func setHiddenWithAnimation(_ isHidden: Bool) {
        switch isHidden {
        case true: // 숨김
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
            } completion: { _ in
                self.isHidden = true
                self.alpha = 1
            }
        case false: // 보여줌
            alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
    
    func setFrame(with center: CGPoint, size: CGSize) {
        self.frame = CGRect(origin: .zero, size: size)
        self.center = center
    }
    
    func renderImage(with croppedRect: CGRect) -> UIImage {
        var newBounds = bounds
        newBounds.origin = CGPoint(x: -croppedRect.origin.x,
                                   y: -croppedRect.origin.y)
        
        let renderer = UIGraphicsImageRenderer(size: croppedRect.size)
        return renderer.image { context in
            drawHierarchy(in: newBounds, afterScreenUpdates: true)
        }
    }
}
