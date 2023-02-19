//
//  PhotoPickerTitleView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit

import RxCocoa
import RxSwift
import Then

class PhotoPickerTitleView: UIView {
    
    var disposeBag = DisposeBag()
    
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
    var setPhotoPicker = BehaviorRelay<PhotoPicker>(value: PhotoPicker.photos)
    
    lazy var photoPicker = setPhotoPicker.asDriver()
    
    // MARK: - UI
    let titleLabel = UILabel().then {
        $0.font = .title
    }
    
    let arrowImageView = UIImageView()
    
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
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    // MARK: -
    func bind() {
        albumButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                let newValue: PhotoPicker = owner.setPhotoPicker.value == .photos ? .albums : .photos
                owner.setPhotoPicker.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        photoPicker
            .drive(with: self, onNext: { owner, photoPicker in
                owner.arrowImageView.image = photoPicker.arrowImage
            })
            .disposed(by: disposeBag)
    }
}
