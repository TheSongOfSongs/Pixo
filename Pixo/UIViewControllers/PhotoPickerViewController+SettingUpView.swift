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
    }
    
    func setupConstriants() {
        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
    }
}
