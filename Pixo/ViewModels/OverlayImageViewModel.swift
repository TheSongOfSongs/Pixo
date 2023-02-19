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
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    private let svgImageSections = BehaviorRelay<[SVGImageSection]>(value: [])
    private let alert = PublishSubject<AlertType>()
    
    // MARK: - properties
    let svgImageManager = SVGImageManager()
    var pageToken: String?
    var svgImageReferences: [SVGImage] {
        return svgImageSections.value.first?.items ?? []
    }
    
    // MARK: - life cycle
    deinit {
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        /// 더 이상 추가할 이미지가 없을 경우
        let noMoreImages = PublishSubject<Void>()
        
        input.fetchSVGImageSections
            .subscribe(onNext: {  _ in
                Task {
                    let result = await self.svgImageManager.fetchSVGImages(with: self.pageToken)
                    
                    switch result {
                    case .success(let result):
                        let items = self.svgImageReferences + result.storageReferences.map({ SVGImage(storageReference: $0) })
                        self.pageToken = result.pageToken
                        self.svgImageSections.accept([SVGImageSection(items: items)])
                        
                        if self.pageToken == nil {
                            noMoreImages.onNext(())
                        }
                    case .failure(let error):
                        NSLog("❗️ error ==> \(error.localizedDescription)")
                        self.alert.onNext(.failToFetchFromStorage)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        return Output(svgImageSections: svgImageSections.asObservable(),
                      noMoreImages: noMoreImages.asObservable(),
                      alert: alert.asDriver(onErrorJustReturn: .unknown))
    }
}
