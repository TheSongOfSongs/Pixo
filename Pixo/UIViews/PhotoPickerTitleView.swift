//
//  PhotoPickerTitleView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Then

class PhotoPickerTitleView: UIView {
    
    let disposeBag = DisposeBag()
    
    enum PhotoPicker {
        case albums
        case photos
        
        var arrowImage: UIImage? {
            switch self {
            case .albums:
                return UIImage(named: "upArrow")
            case .photos:
                return UIImage(named: "downArrow")
            }
        }
    }
    
    /// 현재 화면에 앨범 리스트를 띄우는지, 사진 리스트를 띄우는지 상태를 정해주는 프로퍼티
    var photoPickerRelay = BehaviorRelay<PhotoPicker>(value: PhotoPicker.albums)
    
    lazy var photoPickerDriver = photoPickerRelay.asDriver()
    
    // MARK: - UI
    let titleLabel = UILabel().then {
        $0.font = .title
        $0.text = "Albums"
    }
    
    lazy var arrowImageView = UIImageView().then {
        $0.image = photoPickerRelay.value.arrowImage
    }
    
    let grayBottomBorderView = UIView().then {
        $0.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    }
    
    let albumButton = UIButton()
    
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: -
    func bind() {
        albumButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                let newValue: PhotoPicker = owner.photoPickerRelay.value == .photos ? .albums : .photos
                owner.photoPickerRelay.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        photoPickerDriver
            .drive(with: self, onNext: { owner, photoPicker in
                owner.arrowImageView.image = photoPicker.arrowImage
            })
            .disposed(by: disposeBag)
    }
}
