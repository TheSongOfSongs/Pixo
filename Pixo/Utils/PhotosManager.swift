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

typealias FetchingPHAssetImageSource = (phAsset: PHAsset, targetSize: CGSize)

/// 앨범 사진 관련된 작업을 담당하는 클래스입니다.
final class PhotosManager {
    
    struct Input {
        let fetchImage: Observable<FetchingPHAssetImageSource>
    }
    
    struct Output {
        let progress: Driver<Double>
        let image: Driver<UIImage?>
        let checkiCloudPHAssetImage: Driver<Bool>
    }
    
    // MARK: - properties
    let manager = PHImageManager.default()
    let disposeBag = DisposeBag()
    private let progressRelay = PublishRelay<Double>()
    private let phAssetImageRelay = PublishRelay<UIImage?>()
    private let checkiCloudImageRelay = PublishRelay<Bool>()
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchImage
            .subscribe(with: self, onNext: { owner, result in
                owner.fetchPhoto(of: result.0, targetSize: result.1)
            })
            .disposed(by: disposeBag)
        
        return Output(progress: progressRelay.asDriver(onErrorJustReturn: 0),
                      image: phAssetImageRelay.asDriver(onErrorJustReturn: nil),
                      checkiCloudPHAssetImage: checkiCloudImageRelay.asDriver(onErrorJustReturn: false))
    }
    
    func fetchPhoto(of phAsset: PHAsset, targetSize: CGSize) {
        let isLocalImage: Bool = {
            if let isLocalPHAsset = PHAssetResource
                .assetResources(for: phAsset)
                .first?.value(forKey: "locallyAvailable") as? Bool,
               isLocalPHAsset {
                return true
            } else {
                return false
            }
        }()
        
        checkiCloudImageRelay.accept(!isLocalImage)
        
        // 사진 가져오는 작업 상태 프로그래스 관련 작업
        let options = PHImageRequestOptions().then {
            $0.deliveryMode = .highQualityFormat
            $0.isNetworkAccessAllowed = true
            
            // iCloud에서 로딩해야 하는 경우
            guard !isLocalImage else { return }
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
