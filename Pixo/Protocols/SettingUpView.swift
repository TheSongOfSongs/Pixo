//
//  SettingUpView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

/// UIView, UIViewController에서 채택하여 view를 구성하는 동작을 정의합니다.
protocol SettingUpView {
    func setupLayout()
    /// UIView Element를 추가해주는 함수
    func addSubviews()
    /// UIView Element의 AutoLayout을 잡아주는 함수
    func setupConstriants()
}

extension SettingUpView {
    func setupLayout() {
        addSubviews()
        setupConstriants()
    }
}
