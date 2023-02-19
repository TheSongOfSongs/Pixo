//
//  ExportSettingType.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// 이미지 추출 옵션의 종류입니다.
enum ExportSettingType: Int, CaseIterable {
    case format = 0
    case quality
    
    var name: String {
        switch self {
        case .format:
            return "포맷"
        case .quality:
            return "이미지 품질"
        }
    }
}
