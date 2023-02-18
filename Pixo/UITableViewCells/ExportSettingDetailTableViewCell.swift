//
//  ExportSettingDetailTableViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit

class ExportSettingDetailTableViewCell: UITableViewCell {
    
    // MARK: - properties UI
    let titleLabel = UILabel().then {
        $0.textColor = .pink
        $0.font = .systemFont(ofSize: 16, weight: .heavy)
    }
    
    let subtitleLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 13, weight: .light)
    }

    // MARK: - lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .beige
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SettingUpView
extension ExportSettingDetailTableViewCell: SettingUpView {
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    func setupConstriants() {
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().offset(19)
            make.height.equalTo(20)
            make.bottom.equalTo(snp.centerY)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
        }
    }
}
