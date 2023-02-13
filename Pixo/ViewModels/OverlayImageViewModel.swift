//
//  OverlayImageViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import Foundation
import RxSwift
import RxRelay

class OverlayImageViewModel: ViewModel {
    
    struct Input {
        var fetchSVGImageSections: Observable<Void>
    }
    
    struct Output {
        var svgImageSections: Observable<[SVGImageSection]>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    private let svgImageSectionsSubject = BehaviorSubject<[SVGImageSection]>(value: [])
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchSVGImageSections
            .subscribe(with: self, onNext: { owner, _ in
                let section = SVGImageSection(items: owner.svgImages())
                owner.svgImageSectionsSubject.onNext([section])
            })
            .disposed(by: disposeBag)
        
        return Output(svgImageSections: svgImageSectionsSubject.asObservable())
    }
    
    private func svgImages() -> [SVGImage] {
        var images: [SVGImage] = []
        for i in 1...14 {
            let name: String = {
                if i < 10 {
                    return "00\(i)"
                } else if i < 100 {
                    return "0\(i)"
                } else {
                    return "\(i)"
                }
            }()
            
            images.append(SVGImage(name: name))
        }
        
        return images
    }
}
