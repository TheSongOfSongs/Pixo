//
//  UIImageView+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import UIKit

extension UIImageView {
    /// 이미지 뷰의 contentMode가 scaleAspectFit으로 정의되어 있을 때,
    /// 이미지 뷰에서 실제 이미지가 차지하는 영역만큼의 넓이를 가져옵니다.
    var imageBounds: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0,
              image.size.height > 0 else {
            return bounds
        }
        
        let scale: CGFloat = {
            let widthScale = frame.size.width / image.size.width
            let heightScale = frame.size.height / image.size.height
            return min(widthScale, heightScale)
        }()
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
