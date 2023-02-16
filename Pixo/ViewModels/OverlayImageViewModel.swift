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

class OverlayImageViewModel: NSObject, ViewModel {
    struct Input {
        var fetchSVGImageSections: Observable<Void>
        let requestPHAssetImage: Observable<(PHAsset, CGSize)>
        let saveToAlbum: Observable<UIImage>
    }
    
    struct Output {
        var svgImageSections: Observable<[SVGImageSection]>
        let noMoreImages: Observable<Void>
        let phAssetImageprogress: Driver<Double>
        let phAssetImage: Driver<UIImage?>
        let alert: Driver<AlertType>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    private let svgImageSectionsRelay = BehaviorRelay<[SVGImageSection]>(value: [])
    private let alertSubject = PublishSubject<AlertType>()
    let photosManager = PhotosManager()
    let svgImageManager = SVGImageManager()
    var pageToken: String?
    
    var svgImageReferences: [StorageReference] {
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
                        let items = self.svgImageReferences + result.0
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
        
        input.saveToAlbum
            .bind(with: self, onNext: { owner, image in
                owner.saveToAlbums(image)
            })
            .disposed(by: disposeBag)
        
        let photosManagerInput = PhotosManager.Input(requestImage: input.requestPHAssetImage)
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        return Output(svgImageSections: svgImageSectionsRelay.asObservable(),
                      noMoreImages: noMoreImages.asObservable(),
                      phAssetImageprogress: photosManagerOutput.progress,
                      phAssetImage: photosManagerOutput.image,
                      alert: alertSubject.asDriver(onErrorJustReturn: .unknown))
    }
    
    func saveToAlbums(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(showAlertOfSavingAlbums),
                                       nil)
    }
    
    @objc func showAlertOfSavingAlbums(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            NSLog("❗️ error ==> \(error.localizedDescription)")
            alertSubject.onNext(.failToSavePhoto)
            return
        }
        
        alertSubject.onNext(.successToSavePhoto)
    }
}
