//
//  Quality.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// 이미지 추출 시 해상도에 대한 정보를 나타냅니다
struct Quality: ExportSetting {
    
    let type: ExportSettingType = .quality
    
    /// 사진의 해상도를 나타내는 값 이름
    var title: String
    
    /// 사진의 해상도에 대한 정보
    var subtitle: String
    
    /// 사진을 추출할 때 원본사이즈에 대한 scale 값
    var scale: Double
    
    init(title: String, subtitle: String, scale: Double) {
        self.title = title
        self.subtitle = subtitle
        self.scale = scale
    }
}
