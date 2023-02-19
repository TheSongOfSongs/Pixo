//
//  ViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import Foundation
import RxSwift

/// view model에서 채택하여 사용되는 protocol입니다.
protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
