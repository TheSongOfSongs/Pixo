//
//  ProgressCircleView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/17.
//

import UIKit
import RxSwift
import RxCocoa

/// Pie 형식의 progress와 메시지를 함께 보여주는 뷰입니다.
class ProgressCircleView: UIView {
    
    // MARK: - properties
    let pieProgressViewSize = CGSize(width: 25, height: 25)
    let pieProgressColor = UIColor(r: 250, g: 120, b: 123)
    let pieTrackColor = UIColor(r: 240, g: 239, b: 240)
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    let progress = BehaviorRelay<Double>(value: 0)
    
    
    // MARK: - properties UI
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    lazy var pieProgressView = PieProgressView(frame: CGRect(origin: .zero, size: pieProgressViewSize),
                                               progressColor: pieProgressColor,
                                               trackColor: pieTrackColor)
    
    
    // MARK: - life cycle
    init(frame: CGRect, title: String) {
        super.init(frame: frame)
        setupLayout()
        bind()
        
        backgroundColor = pieTrackColor
        titleLabel.text = title
        makeCornerRounded(radius: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func bind() {
        progress
            .asDriver()
            .drive(with: self, onNext: { owner, value in
                owner.pieProgressView.progress = value
            })
            .disposed(by: disposeBag)
    }
}
