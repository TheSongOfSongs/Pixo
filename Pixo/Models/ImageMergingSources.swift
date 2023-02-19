//
//  ImageMergingSources.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import Photos

/// 배경이미지와 오버레이 이미지를 합성하기 위해 필요한 정보입니다.
struct ImageMergingSources {
    /// 배경이미지로 사용될 사진을 담고 있는 PHAsset.
    /// image view에 띄어진 이미지와 원본이미지는 사이즈가 다르기 때문에 PHAsset이 필요
    let phAsset: PHAsset
    
    /// 배경이미지가 띄어진 image view
    let backgroundImageView: UIImageView
    
    /// 배경이미지 위에 얹어진 오버레이 이미지들의 [image view]
    let overlayImageViews: [UIImageView]
    
    init(phAsset: PHAsset, backgroundImageView: UIImageView, overlayImageViews: [UIImageView]) {
        self.phAsset = phAsset
        self.backgroundImageView = backgroundImageView
        self.overlayImageViews = overlayImageViews
    }
}
