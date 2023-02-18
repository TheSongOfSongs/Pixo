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
        let exportOptions: Observable<(Format?, Quality?)>
    }
    
    struct Output {
        let formats: [ExportSetting]
        let qualities: [ExportSetting]
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
        let fetchPHAssetImage = PublishSubject<FetchingPHAssetImageSource>()
        let phAsset = input.phAsset
        let photosManagerInput = PhotosManager.Input(fetchImage: fetchPHAssetImage.asObservable())
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        let formats = [
            Format(title: "JPEG", subtitle: "투명도 없음. 공유하기에 가장 좋습니다.", format: .jpeg),
            Format(title: "PNG", subtitle: "투명도를 갖춘 최상의 이미지 품질", format: .png)
        ]
        
        let qualities = [
            Quality(title: "낮은", subtitle: "\(Int(phAsset.pixelWidth/2)) x \(Int(phAsset.pixelHeight/2))", scale: 0.5),
            Quality(title: "최적", subtitle: "\(Int(phAsset.pixelWidth)) x \(Int(phAsset.pixelHeight))", scale: 1),
            Quality(title: "높은", subtitle: "\(Int(phAsset.pixelWidth*2)) x \(Int(phAsset.pixelHeight*2))", scale: 2)
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
        
        Observable.zip(imageMergingSourcesSubject, photosManagerOutput.image.asObservable(), input.exportOptions)
            .subscribe(with: self, onNext: { owner, result in
                guard let backgroundImage = result.1 else {
                    owner.alertSubject.onNext(.failToSavePhoto)
                    return
                }
                
                let mergingSources = result.0
                let options = result.2
                let exportSources = ImageExportSources(backgroundImage: backgroundImage,
                                                       backgroundImageBounds: mergingSources.backgroundImageView.imageBounds,
                                                       overlayImageViews: mergingSources.overlayImageViews,
                                                       format: options.0,
                                                       quality: options.1)

                guard let image = ExportManager(source: exportSources).mergeImage() else {
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
