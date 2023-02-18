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


typealias ImageMergingSources = (phAsset: PHAsset, backgroundImageView: UIImageView, overlayImageViews: [UIImageView])

class OverlayImageViewModel: NSObject, ViewModel {
    
    struct Input {
        var fetchSVGImageSections: Observable<Void>
        let saveToAlbum: Observable<UIImage>
        let mergeAndExportImage: Observable<(ImageMergingSources)>
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
    private let imageMergingSourcesSubject = PublishSubject<ImageMergingSources>()
    
    let photosManager = PhotosManager()
    let svgImageManager = SVGImageManager()
    var pageToken: String?
    
    var svgImageReferences: [SVGImage] {
        return svgImageSectionsRelay.value.first?.items ?? []
    }
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        let noMoreImages = PublishSubject<Void>()
        let fetchPHAssetImage = PublishSubject<(PHAsset, CGSize)>()
        let photosManagerInput = PhotosManager.Input(requestImage: fetchPHAssetImage.asObservable())
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
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
        
        input.saveToAlbum
            .bind(with: self, onNext: { owner, image in
                owner.saveToAlbums(image)
            })
            .disposed(by: disposeBag)
        
        input.mergeAndExportImage
            .bind(with: self, onNext: { owner, sources in
                owner.imageMergingSourcesSubject.onNext(sources)
                
                let phAsset = sources.phAsset
                fetchPHAssetImage.onNext((phAsset,
                                          CGSize(width: phAsset.pixelWidth,
                                                 height: phAsset.pixelHeight)))
            })
            .disposed(by: disposeBag)
        
        Observable.zip(imageMergingSourcesSubject, photosManagerOutput.image.asObservable())
            .subscribe(with: self, onNext: { owner, result in
                let sources = result.0
               
                guard let backgroundImage = result.1 else {
                    owner.alertSubject.onNext(.failToSavePhoto)
                    return
                }
                
                let exportManager = ExportManager(backgroundImage: backgroundImage,
                                                  backgroundImageBounds: sources.backgroundImageView.imageBounds,
                                                  overlayImageViews: sources.overlayImageViews)
                
                guard let image = exportManager.mergeImage() else {
                    owner.alertSubject.onNext(.failToSavePhoto)
                    return
                }
                
                owner.saveToAlbums(image)
            })
            .disposed(by: disposeBag)
        

        return Output(svgImageSections: svgImageSectionsRelay.asObservable(),
                      noMoreImages: noMoreImages.asObservable(),
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
