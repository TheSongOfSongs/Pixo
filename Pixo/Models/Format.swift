//
//  Format.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// 이미지 추출 시 파일 타입에 대한 정보를 나타냅니다
struct Format: ExportSetting {
    
    let type: ExportSettingType = .format
    var title: String
    var subtitle: String
    var imageType: ImageFormatType
    
    init(title: String, subtitle: String, format: ImageFormatType) {
        self.title = title
        self.subtitle = subtitle
        self.imageType = format
    }
}
