//
//  UIColor+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

extension UIColor {
    /// RGBA 값을 0~255 범위로 받아 연산을 하여 색상 정의
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: alpha)
    }
    
    // static constants
    static let beige = UIColor(r: 247, g: 248, b: 249)
    static let pink = UIColor(r: 250, g: 120, b: 120)
}
