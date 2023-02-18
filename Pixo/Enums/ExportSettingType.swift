//
//  ExportSettingType.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// TableView의 InexPath row를 구분하기 위한 타입
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
