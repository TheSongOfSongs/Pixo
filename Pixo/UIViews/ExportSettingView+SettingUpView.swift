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
            make.top.equalTo(selectedExportSettingTableView.snp.top)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        selectedExportSettingTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(safeAreaInsets.bottom + 50)
            make.height.equalTo(160)
        }
    }
}
