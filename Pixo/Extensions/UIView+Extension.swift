//
//  UIView+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

extension UIView {
    
    enum GradientDirection {
        case horizontal
        case vertical
    }
    
    class var identifier: String {
        return String(describing: self)
    }
    
    func makeCornerRounded(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    func makeUpperCornerRounded(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func addGradientLayer(colors: [UIColor], direction: GradientDirection) {
        // 그라데이션 레이어 추가 전, 이전에 추가된 그라데이션 레이어는 모두 제거
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // 그라데이션 레이어 추가
        layer.addSublayer(gradientLayer(colors: colors.map({ $0.cgColor }), direction: direction))
    }
    
    func addBorder(color: UIColor, width: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    private func gradientLayer(colors: [Any], direction: GradientDirection = .vertical) -> CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        gradientLayer.zPosition = -1
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        
        if direction == .horizontal {
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
        
        return gradientLayer
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
}
