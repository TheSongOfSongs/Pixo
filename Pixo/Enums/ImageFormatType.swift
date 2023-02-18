//
//  ImageFormatType.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

enum ImageFormatType {
    case png
    case jpg
    
    var opaque: Bool {
        switch self {
        case .png:
            return true
        case .jpg:
            return false
        }
    }
}
