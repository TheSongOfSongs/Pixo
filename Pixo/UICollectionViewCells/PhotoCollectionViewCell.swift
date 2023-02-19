//
//  PhotoCollectionViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import SnapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: properties
    var representedAssetIdentifier: String = ""
    
    // MARK: properties UI
    let imageView = UIImageView().then {
        $0.makeCornerRounded(radius: 16)
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage.photo
    }
    
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage.photo
    }
}


// MARK: - SettingUpView
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
