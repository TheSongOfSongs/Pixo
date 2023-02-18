//
//  ImageMergingSources.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import Photos

struct ImageMergingSources {
    let phAsset: PHAsset
    let backgroundImageView: UIImageView
    let overlayImageViews: [UIImageView]
    
    init(phAsset: PHAsset, backgroundImageView: UIImageView, overlayImageViews: [UIImageView]) {
        self.phAsset = phAsset
        self.backgroundImageView = backgroundImageView
        self.overlayImageViews = overlayImageViews
    }
}
