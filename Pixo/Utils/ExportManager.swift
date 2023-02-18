//
//  ExportManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit

struct ExportManager {
    
    // MARK: - properties
    /// 배경이미지. 합성할 이미지의 배경이 되는 이미지
    let backgroundImage: UIImage
    
    /// 배경이미지가 화면에 표시되었을 때, image view 안에서 실제로 보여지던 영역
    let backgroundImageBounds: CGRect
    
    /// 배경이미지 위에 얹을 이미지의 image view 배열
    let overlayImageViews: [UIImageView]
    
    /// 배경이미지의 사이즈
    var backgroundImageSize: CGSize
    
    /// 이미지 추출 시 scale 값으로 해상도 조정
    var quality: Quality?
    
    /// 이미지 추출 시 이미지 파일 타입 지정
    var format: Format?
    
    var opaque: Bool {
        return format?.imageType.opaque ?? false
    }
    
    var scale: Double {
        return quality?.scale ?? 1
    }
    
    
    // MARK: - init
    init(source: ImageExportSources) {
        self.backgroundImage = source.backgroundImage
        self.backgroundImageBounds = source.backgroundImageBounds
        self.overlayImageViews = source.overlayImageViews
        self.backgroundImageSize = backgroundImage.size
        self.quality = source.quality
        self.format = source.format
    }
    
    // MARK: - helpers
    /// 배경이미지 위에 오버레이 이미지들을 얹어서 합성하여 결과물을 반환합니다.
    func mergeImage() -> UIImage? {
        let defaultImageSize = backgroundImage.size
        
        UIGraphicsBeginImageContextWithOptions(defaultImageSize, opaque, scale)
        
        // 1. 배경이미지 그리기
        backgroundImage.draw(at: .zero)
        
        // 2. 오버레이 이미지 그리기
        overlayImageViews.forEach { overlayImageView in
            guard let overlayImage = overlayImageView.image else { return }
            
            let frame = svgImageRect(svgImageViewFrame: overlayImageView.frame)
            overlayImage.draw(in: frame)
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /// 이미지 합성 시, defaultImageView의 원본 이미지와 defaultImageView의 frame과 bounds 값을 고려하여 SVG 이미지를 그릴 영역의 frame을 반환합니다.
    func svgImageRect(svgImageViewFrame: CGRect) -> CGRect {
        let origin: CGPoint = {
            let x = backgroundImageSize.width * (svgImageViewFrame.origin.x - backgroundImageBounds.origin.x) / backgroundImageBounds.width
            let y = backgroundImageSize.height * (svgImageViewFrame.origin.y - backgroundImageBounds.origin.y) / backgroundImageBounds.height
            return CGPoint(x: x, y: y)
        }()
        
        let width = svgImageViewFrame.width * backgroundImageSize.width / backgroundImageBounds.width
        let size = CGSize(width: width, height: width) // 이미지 비율 1:1
        return CGRect(origin: origin, size: size)
    }
}
