//
//  ImageFormatType.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// 합성한 이미지를 타입의 종류별로 선택하여 추출할 수 있습니다.
enum ImageFormatType {
    case png
    case jpeg
    
    var opaque: Bool {
        switch self {
        case .png:
            return false
        case .jpeg:
            return true
        }
    }
}
