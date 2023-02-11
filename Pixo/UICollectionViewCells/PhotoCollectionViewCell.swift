//
//  PhotoCollectionViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import SnapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI
    let imageView = UIImageView().then {
        $0.makeCornerRounded(radius: 16)
        $0.contentMode = .scaleAspectFill
    }
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoCollectionViewCell: SettingUpView {
    func addSubviews() {
        addSubview(imageView)
    }
    
    func setupConstriants() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
