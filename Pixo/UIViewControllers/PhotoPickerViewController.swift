//
//  PhotoPickerViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoPickerViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    // MARK: UI
    let titleView = PhotoPickerTitleView(frame: .zero)
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
    }

    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    
    // MARK: -
    func bind() {
        titleView.photoPickerObservable
            .bind(with: self, onNext: { owner, photoPicker in
                // TODO: 사진/앨범 리스트 보여주기
                print("💖 \(photoPicker)")
            })
            .disposed(by: disposeBag)
    }
}
