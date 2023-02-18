//
//  OverlayImageViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import Foundation
import Photos

import FirebaseStorage
import RxSwift
import RxCocoa

class OverlayImageViewModel: ViewModel {
    
    struct Input {
        var fetchSVGImageSections: Observable<Void>
    }
    
    struct Output {
        var svgImageSections: Observable<[SVGImageSection]>
        let noMoreImages: Observable<Void>
        let alert: Driver<AlertType>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    private let svgImageSectionsRelay = BehaviorRelay<[SVGImageSection]>(value: [])
    private let alertSubject = PublishSubject<AlertType>()
    
    let svgImageManager = SVGImageManager()
    var pageToken: String?
    
    var svgImageReferences: [SVGImage] {
        return svgImageSectionsRelay.value.first?.items ?? []
    }
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        let noMoreImages = PublishSubject<Void>()
        
        input.fetchSVGImageSections
            .subscribe(onNext: { _ in
                Task {
                    let result = await self.svgImageManager.fetchSVGImages(with: self.pageToken)
                    
                    switch result {
                    case .success(let result):
                        let items = self.svgImageReferences + result.0.map({ SVGImage(storageReference: $0) })
                        self.pageToken = result.1
                        self.svgImageSectionsRelay.accept([SVGImageSection(items: items)])
                        
                        if result.1 == nil {
                            noMoreImages.onNext(())
                        }
                    case .failure(let error):
                        NSLog("❗️ error ==> \(error.localizedDescription)")
                        self.alertSubject.onNext(.failToFetchFromStorage)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(svgImageSections: svgImageSectionsRelay.asObservable(),
                      noMoreImages: noMoreImages.asObservable(),
                      alert: alertSubject.asDriver(onErrorJustReturn: .unknown))
    }
}
