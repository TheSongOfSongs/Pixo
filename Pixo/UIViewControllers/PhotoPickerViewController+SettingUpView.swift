//
//  PhotoPickerViewController+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import SnapKit

extension PhotoPickerViewController: SettingUpView {
    func addSubviews() {
        view.addSubview(titleView)
        view.addSubview(tableView)
        view.addSubview(photoCollectionView)
        view.addSubview(progressCircleView)
    }
    
    func setupConstriants() {
        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Constant.navigationBarHeight + view.safeAreaInsets.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        progressCircleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(120)
        }
    }
}
