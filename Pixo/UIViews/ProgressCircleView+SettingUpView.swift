//
//  ProgressCircleView+SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/17.
//

import UIKit

extension ProgressCircleView: SettingUpView {
    func addSubviews() {
        addSubview(pieProgressView)
        addSubview(titleLabel)
    }
    
    func setupConstriants() {
        pieProgressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(pieProgressViewSize.width)
            make.centerY.equalToSuperview().offset(-15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY).offset(24)
            make.centerX.equalToSuperview()
        }
    }
}
