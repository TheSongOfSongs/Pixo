//
//  ViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import Foundation
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output

}
