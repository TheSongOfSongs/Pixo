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

class OverlayImageViewModel: NSObject, ViewModel {
    struct Input {
        var fetchSVGImageSections: Observable<Void>
        let requestPHAssetImage: Observable<(PHAsset, CGSize)>
        let saveToAlbum: Observable<UIImage>
    }
    
    struct Output {
        var svgImageSections: Observable<[SVGImageSection]>
        let phAssetImageprogress: Driver<Double>
        let phAssetImage: Driver<UIImage?>
        let alert: Driver<AlertType>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    private let svgImageSectionsSubject = BehaviorSubject<[SVGImageSection]>(value: [])
    private let alertSubject = PublishSubject<AlertType>()
    let photosManager = PhotosManager()
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchSVGImageSections
            .subscribe(with: self, onNext: { owner, _ in
                let section = SVGImageSection(items: owner.svgImages())
                owner.svgImageSectionsSubject.onNext([section])
            })
            .disposed(by: disposeBag)
        
        input.saveToAlbum
            .bind(with: self, onNext: { owner, image in
                owner.saveToAlbums(image)
            })
            .disposed(by: disposeBag)
        
        let photosManagerInput = PhotosManager.Input(requestImage: input.requestPHAssetImage)
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        return Output(svgImageSections: svgImageSectionsSubject.asObservable(),
                      phAssetImageprogress: photosManagerOutput.progress,
                      phAssetImage: photosManagerOutput.image,
                      alert: alertSubject.asDriver(onErrorJustReturn: .unknown))
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
        }
        
        alertSubject.onNext(.successToSavePhoto)
    }
}
