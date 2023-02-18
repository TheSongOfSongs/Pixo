//
//  ExportSetting.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import Foundation

protocol ExportSetting {
    var type: ExportSettingType { get }
    var title: String { get }
    var subtitle: String { get }
}
