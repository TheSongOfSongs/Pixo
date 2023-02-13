//
//  AlbumTableViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import UIKit
import SnapKit

class AlbumTableViewCell: UITableViewCell {
    
    // MARK: properties - UI
    lazy var previewImageView = UIImageView().then {
        $0.makeCornerRounded(radius: 8)
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage.photo
    }
    
    let titleLabel = UILabel().then {
        $0.font = .title
    }
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = UIImage.photo
    }
}


// MARK: - SettingUpView
extension AlbumTableViewCell: SettingUpView {
    func addSubviews() {
        addSubview(previewImageView)
        addSubview(titleLabel)
    }
    
    func setupConstriants() {
        previewImageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(previewImageView.snp.trailing).offset(17)
            make.centerY.equalToSuperview()
        }
    }
}
