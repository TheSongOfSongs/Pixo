//
//  ImageCollectionViewCell.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: properties UI
    let imageView = UIImageView().then {
        $0.addBorder(color: .black, width: 1)
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
    }
}


// MARK: - SettingUpView
extension ImageCollectionViewCell: SettingUpView {
    func addSubviews() {
        addSubview(imageView)
    }
    
    func setupConstriants() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
