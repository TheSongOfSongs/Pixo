//
//  PhotosManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import Foundation
import Photos

import RxSwift
import RxCocoa

/// 앨범 사진 관련된 작업을 담당하는 클래스입니다.
final class PhotosManager {
    
    struct Input {
        let requestImage: Observable<(PHAsset, CGSize)>
    }
    
    struct Output {
        let progress: Driver<Double>
        let image: Driver<UIImage?>
    }
    
    // MARK: - properties
    let manager = PHImageManager.default()
    let disposeBag = DisposeBag()
    private let progressRelay = PublishRelay<Double>()
    private let phAssetImageRelay = PublishRelay<UIImage?>()
    
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.requestImage
            .subscribe(with: self, onNext: { owner, result in
                owner.fetchPhoto(of: result.0, targetSize: result.1)
            })
            .disposed(by: disposeBag)
        
        return Output(progress: progressRelay.asDriver(onErrorJustReturn: 0),
                      image: phAssetImageRelay.asDriver(onErrorJustReturn: nil))
    }
    
    func fetchPhoto(of phAsset: PHAsset, targetSize: CGSize) {
        // 사진 가져오는 작업 상태 프로그래스 관련 작업
        let options = PHImageRequestOptions().then {
            $0.deliveryMode = .highQualityFormat
            $0.isNetworkAccessAllowed = true
            $0.progressHandler = { [weak self] progress, _, _, _ in
                self?.progressRelay.accept(progress)
            }
        }
        
        // 사진 요청
        manager.requestImage(for: phAsset,
                             targetSize: targetSize,
                             contentMode: .aspectFit,
                             options: options) { [weak self] image, _ in
            self?.phAssetImageRelay.accept(image)
        }
    }
}
