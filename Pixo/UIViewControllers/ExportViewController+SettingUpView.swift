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
        
        overlayImageViews.forEach { imageView in
            phAssetImageView.addSubview(imageView)
        }
    }
    
    func setupConstriants() {
        phAssetImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(exportSettingView.snp.top)
        }
        
        exportSettingView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(220)
        }
    }
}
