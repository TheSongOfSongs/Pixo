//
//  ExportSetting.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

/// 이미지 추출 옵션 모델이 채택하는 protocol 입니다.
protocol ExportSetting {
    var type: ExportSettingType { get }
    var title: String { get }
    var subtitle: String { get }
}
