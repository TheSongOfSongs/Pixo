//
//  ExportViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import Photos

import RxCocoa
import RxSwift

class ExportViewModel: NSObject, ViewModel {
    
    struct Input {
        let phAsset: PHAsset
        let mergeAndExportImage: Observable<(ImageMergingSources)>
    }
    
    struct Output {
        let formats: [ExportSettig]
        let qualities: [ExportSettig]
        let alert: Driver<AlertType>
    }
    
    // MARK: - properties
    let photosManager = PhotosManager()
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    private let alertSubject = PublishSubject<AlertType>()
    private let imageMergingSourcesSubject = PublishSubject<ImageMergingSources>()
    
    // MARK: - life cycle
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        let fetchPHAssetImage = PublishSubject<(PHAsset, CGSize)>()
        let phAsset = input.phAsset
        let photosManagerInput = PhotosManager.Input(requestImage: fetchPHAssetImage.asObservable())
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        let formats = [
            ExportSettig(title: "JPG", subtitle: "투명도 없음. 공유하기에 가장 좋습니다."),
            ExportSettig(title: "PNG", subtitle: "투명도를 갖춘 최상의 이미지 품질")
        ]
        
        let qualities = [
            ExportSettig(title: "낮은", subtitle: "\(Int(phAsset.pixelWidth/2)) x \(Int(phAsset.pixelHeight/2))"),
            ExportSettig(title: "최적", subtitle: "\(Int(phAsset.pixelWidth)) x \(Int(phAsset.pixelHeight))"),
            ExportSettig(title: "높은", subtitle: "\(Int(phAsset.pixelWidth*2)) x \(Int(phAsset.pixelHeight*2))")
        ]
        
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
        
        return Output(formats: formats,
                      qualities: qualities,
                      alert: alertSubject.asDriver(onErrorJustReturn: .unknown)
        )
    }
    
    private func saveToAlbums(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(showAlertOfSavingAlbums),
                                       nil)
    }
    
    @objc private func showAlertOfSavingAlbums(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            NSLog("❗️ error ==> \(error.localizedDescription)")
            alertSubject.onNext(.failToSavePhoto)
            return
        }
        
        alertSubject.onNext(.successToSavePhoto)
    }
}
