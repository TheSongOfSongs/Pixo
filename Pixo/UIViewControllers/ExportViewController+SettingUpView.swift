//
//  ExportViewController+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit

extension ExportViewController: SettingUpView {
    func addSubviews() {
        view.addSubview(phAssetImageView)
        view.addSubview(exportSettingView)
        view.addSubview(exportButton)
    }
    
    func setupConstriants() {
        phAssetImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(exportSettingView.snp.top)
        }
        
        exportButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            make.height.equalTo(60)
        }
        
        exportSettingView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(exportButton.snp.top)
            make.height.equalTo(200)
        }
    }
}
