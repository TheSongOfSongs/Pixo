//
//  PhotoPickerTitleView+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

extension PhotoPickerTitleView: SettingUpView {
    func setupView() {
        addSubview(titleLabel)
        addSubview(arrowImageView)
        addSubview(grayBottomBorderView)
        addSubview(albumButton)
    }
    
    func setupConstriants() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.width.equalTo(18)
            make.height.equalTo(10)
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.centerY.equalTo(titleLabel)
        }
        
        grayBottomBorderView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        albumButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(titleLabel).inset(100)
            make.leading.equalTo(titleLabel).offset(-60)
            make.trailing.equalTo(arrowImageView).offset(50)
        }
    }
}
