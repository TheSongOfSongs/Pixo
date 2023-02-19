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
        view.addSubview(overlayImageCollectionView)
        view.addSubview(phAssetImageBackgroundView)
        phAssetImageBackgroundView.addSubview(phAssetImageView)
    }
    
    func setupConstriants() {
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(Constant.navigationBarHeight + view.safeAreaInsets.top + 10)
        }
        
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.bottom.equalTo(topView).inset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        overlayButton.snp.makeConstraints { make in
            make.width.equalTo(103)
            make.height.equalTo(33)
            make.bottom.equalTo(topView).inset(14)
            make.trailing.equalToSuperview().inset(19)
        }
        
        overlayImageCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(151.0 + UIApplication.safeAreaBottomInset)
        }
        
        phAssetImageBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(overlayImageCollectionView.snp.top)
        }
        
        phAssetImageView.snp.makeConstraints { make in
            make.edges.equalTo(phAssetImageBackgroundView)
        }
    }
}
