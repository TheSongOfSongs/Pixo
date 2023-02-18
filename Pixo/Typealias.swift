//
//  Typealias.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import Photos

/// PHAsset 사진과 오버레이 이미지 합성을 위해 필요한 데이터
typealias ImageMergingSources = (phAsset: PHAsset, backgroundImageView: UIImageView, overlayImageViews: [UIImageView])
