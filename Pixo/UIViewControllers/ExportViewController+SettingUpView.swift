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
        view.addSubview(bottomSheetView)
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
        
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
            make.top.equalTo(view.snp.bottom)
        }
    }
    
    func showBottomSheetView() {
        bottomSheetView.snp.updateConstraints { make in
            make.top.equalTo(view.snp.bottom).inset(view.frame.height - exportSettingView.frame.minY)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideBottomSheetView() {
        bottomSheetView.snp.updateConstraints { make in
            make.top.equalTo(view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
