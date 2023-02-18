//
//  ExportSettingTableViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit

class ExportSettingTableViewCell: UITableViewCell {
    
    // MARK: - properties UI
    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = .pink
        $0.font = .systemFont(ofSize: 16, weight: .heavy)
    }
    
    let subtitleLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 10, weight: .light)
    }

    // MARK: - lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = .beige
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SettingUpView
extension ExportSettingTableViewCell: SettingUpView {
    func addSubviews() {
        addSubview(nameLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    func setupConstriants() {
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(40)
            make.bottom.equalTo(snp.centerY)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY)
            make.trailing.equalToSuperview().inset(40)
        }
    }
    
    func updateConstraintsWhenNoSubtitle() {
        titleLabel.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(40)
            make.centerY.equalToSuperview()
        }
        subtitleLabel.isHidden = true
    }
    
    func updateConstraintsWhenSubtitleExists(){
        subtitleLabel.snp.remakeConstraints { make in
            make.top.equalTo(snp.centerY).offset(3)
            make.trailing.equalTo(titleLabel)
        }
        subtitleLabel.isHidden = false
    }
}
