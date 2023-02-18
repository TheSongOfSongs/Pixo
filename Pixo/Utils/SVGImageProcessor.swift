//
//  SVGImageProcessor.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/15.
//

import Foundation
import SVGKit
import Kingfisher

/// 이미지 가공 시 사용되는 ImageProcessor로 svg 이미지를 Data에서 UIImage로 변환합니다.
struct SVGImgProcessor: ImageProcessor {
    
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return SVGKImage(data: data)?.uiImage
        }
    }
}
