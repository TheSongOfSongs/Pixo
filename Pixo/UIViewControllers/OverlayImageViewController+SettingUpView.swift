//
//  OverlayImageViewController+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit

extension OverlayImageViewController: SettingUpView {
    func addSubviews() {
        view.addSubview(topView)
        topView.addSubview(closeButton)
        topView.addSubview(overlayButton)
        view.addSubview(collectionView)
    }
    
    func setupConstriants() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.equalToSuperview().offset(29)
            make.leading.equalToSuperview().offset(16)
        }
        
        overlayButton.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.width.equalTo(103)
            make.height.equalTo(33)
            make.trailing.equalToSuperview().inset(19)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(151)
        }
    }
}
