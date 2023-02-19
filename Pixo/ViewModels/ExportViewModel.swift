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

typealias ExportOptions = (format: Format?, quality: Quality?)

class ExportViewModel: NSObject, ViewModel {
    
    struct Input {
        let phAsset: PHAsset
        let mergeAndExportImage: Observable<(ImageMergingSources)>
        let format: Observable<Format?>
        let quality: Observable<Quality?>
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
    private let alert = PublishSubject<AlertType>()
    private let mergeImages = PublishSubject<ImageMergingSources>()
    
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
                // 이미지 합성 위한 데이터 전달
                owner.mergeImages.onNext(sources)
                
                // 원본 이미지 요청
                let phAsset = sources.phAsset
                let targetSize = CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight)
                fetchPHAssetImage.onNext((phAsset: phAsset,
                                          targetSize: targetSize))
            })
            .disposed(by: disposeBag)
        
        // 이미지 합성 및 추출 후 앨범 저장
        Observable.zip(mergeImages, photosManagerOutput.image.asObservable(), input.format, input.quality)
            .subscribe(with: self, onNext: { owner, result in
                guard let backgroundImage = result.1 else {
                    owner.alert.onNext(.failToSavePhoto)
                    return
                }
                
                let mergingSources = result.0
                let exportSources = ImageExportSources(backgroundImage: backgroundImage,
                                                       backgroundImageBounds: mergingSources.backgroundImageView.imageBounds,
                                                       overlayImageViews: mergingSources.overlayImageViews,
                                                       format: result.2,
                                                       quality: result.3)
                
                // 합성 결과물 이미지
                guard let image = ExportManager(source: exportSources).mergeImage() else {
                    owner.alert.onNext(.failToSavePhoto)
                    return
                }

                owner.saveToAlbums(image)
            })
            .disposed(by: disposeBag)
        
        return Output(formats: formats,
                      qualities: qualities,
                      alert: alert.asDriver(onErrorJustReturn: .unknown)
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
            alert.onNext(.failToSavePhoto)
            return
        }
        
        alert.onNext(.successToSavePhoto)
    }
}
