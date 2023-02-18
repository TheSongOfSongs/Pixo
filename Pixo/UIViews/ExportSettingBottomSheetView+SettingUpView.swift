//
//  ExportSettingBottomSheetView+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit

extension ExportSettingBottmSheetView: SettingUpView {
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(exportSettingsTableView)
    }
    
    func setupConstriants() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(15)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
        }
        
        exportSettingsTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
}
