//
//  ExportSettingView+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit

extension ExportSettingView: SettingUpView {
    func addSubviews() {
        addSubview(selectedExportSettingTableView)
        addSubview(titleLabel)
    }
    
    func setupConstriants() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(15)
        }
        
        selectedExportSettingTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }
    }
}
