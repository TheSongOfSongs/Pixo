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
    
    /// 추출할 파일 타입에 대한 이름
    var title: String
    
    /// 파일 타입에 대한 설명
    var subtitle: String
    
    /// 파일 타입을 정의한 enum
    var imageType: ImageFormatType
    
    init(title: String, subtitle: String, format: ImageFormatType) {
        self.title = title
        self.subtitle = subtitle
        self.imageType = format
    }
}
