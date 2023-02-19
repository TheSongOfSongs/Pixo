//
//  ImageExportSources.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import Photos

/// 배경이미지와 오버레이 이미지를 추출하기 위해 필요한 정보입니다.
struct ImageExportSources {
    /// 배경이미지. 합성할 이미지의 배경이 되는 이미지
    let backgroundImage: UIImage
    
    /// 배경이미지가 화면에 표시되었을 때, image view 안에서 실제로 보여지던 영역
    let backgroundImageBounds: CGRect
    
    /// 배경이미지 위에 얹을 이미지의 image view 배열
    let overlayImageViews: [UIImageView]
    
    /// 배경이미지의 사이즈
    var backgroundImageSize: CGSize
    
    // 이미지 추출에 대한 옵션
    var format: Format?
    var quality: Quality?
    
    init(backgroundImage: UIImage, backgroundImageBounds: CGRect, overlayImageViews: [UIImageView], format: Format? = nil, quality: Quality? = nil) {
        self.backgroundImage = backgroundImage
        self.backgroundImageBounds = backgroundImageBounds
        self.overlayImageViews = overlayImageViews
        self.backgroundImageSize = backgroundImage.size
        self.format = format
        self.quality = quality
    }
}
