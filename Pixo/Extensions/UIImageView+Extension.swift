//
//  UIImageView+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import UIKit

extension UIImageView {
    var imageBounds: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0,
              image.size.height > 0 else {
            return bounds
        }
        
        let scale: CGFloat = {
            if image.size.width >= image.size.height {
                return bounds.width / image.size.width
            } else {
                return bounds.height / image.size.height
            }
        }()
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
