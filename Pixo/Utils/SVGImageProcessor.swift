//
//  SVGImageProcessor.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/15.
//

import Foundation
import SVGKit
import Kingfisher

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
