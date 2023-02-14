//
//  OverlayImageViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import Foundation
import Photos

import RxSwift
import RxCocoa

class OverlayImageViewModel: ViewModel {
    
    struct Input {
        var fetchSVGImageSections: Observable<Void>
        let requestPHAssetImage: Observable<(PHAsset, CGSize)>
    }
    
    struct Output {
        var svgImageSections: Observable<[SVGImageSection]>
        let phAssetImageprogress: Driver<Double>
        let phAssetImage: Driver<UIImage?>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    private let svgImageSectionsSubject = BehaviorSubject<[SVGImageSection]>(value: [])
    let photosManager = PhotosManager()
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchSVGImageSections
            .subscribe(with: self, onNext: { owner, _ in
                let section = SVGImageSection(items: owner.svgImages())
                owner.svgImageSectionsSubject.onNext([section])
            })
            .disposed(by: disposeBag)
        
        let photosManagerInput = PhotosManager.Input(requestImage: input.requestPHAssetImage)
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        return Output(svgImageSections: svgImageSectionsSubject.asObservable(),
                      phAssetImageprogress: photosManagerOutput.progress,
                      phAssetImage: photosManagerOutput.image
        )
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
