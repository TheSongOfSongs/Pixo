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
    var disposeBag = DisposeBag()
    
    let manager = PHImageManager.default()
    
    private let progress = PublishRelay<Double>()
    private let phAssetImage = PublishRelay<UIImage?>()
    private let checkiCloudImage = PublishRelay<Bool>()
    
    // MARK: - life cycle
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchImage
            .subscribe(with: self, onNext: { owner, result in
                owner.fetchPhoto(of: result)
            })
            .disposed(by: disposeBag)
        
        return Output(progress: progress.asDriver(onErrorJustReturn: 0),
                      image: phAssetImage.asDriver(onErrorJustReturn: nil),
                      checkiCloudPHAssetImage: checkiCloudImage.asDriver(onErrorJustReturn: false))
    }
    
    func fetchPhoto(of source: FetchingPHAssetImageSource) {
        let phAsset = source.phAsset
        
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
        
        checkiCloudImage.accept(!isLocalImage)
        
        // 사진 가져오는 작업 상태 프로그래스 관련 작업
        let options = PHImageRequestOptions().then {
            $0.deliveryMode = .highQualityFormat
            $0.isNetworkAccessAllowed = true
            
            // iCloud에서 로딩해야 하는 경우
            guard !isLocalImage else { return }
            $0.progressHandler = { [weak self] progress, _, _, _ in
                self?.progress.accept(progress)
            }
        }
        
        // 사진 요청
        manager.requestImage(for: phAsset,
                             targetSize: source.targetSize,
                             contentMode: .aspectFit,
                             options: options) { [weak self] image, _ in
            self?.phAssetImage.accept(image)
        }
    }
}
