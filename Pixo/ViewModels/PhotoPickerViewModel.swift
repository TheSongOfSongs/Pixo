//
//  PhotoPickerViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

/// 현재 선택된 앨범 정보와 collection view를 리로드해야하는지 여부를 나타냅니다.
/// 선택된 album이 바뀔 때마다 relay에 값을 넣어주면 구독하는 쪽의 코드에서  collection view를 항상 reload 시킵니다.
/// album 값이 변경되면 collection view의 데이터소스는 업데이트되어야 하지만, collection view를 reload하는게 아니라
/// 변경된 부분만 업데이트시켜줘야 하므로 reload 여부를 Bool 값으로 전달합니다.
typealias AlbumDataSource = (album: Album, shouldReload: Bool)

class PhotoPickerViewModel: ViewModel {
    
    struct Input {
        let fetchAlbums: Observable<Void>
        let fetchPHAssetImage: Observable<FetchingPHAssetImageSource>
        let updateAlbums: Observable<PHChange>
    }
    
    struct Output {
        let albums: Observable<[AlbumSection]>
        let phAssetImageprogress: Driver<Double>
        let phAssetImage: Driver<UIImage?>
        let checkiCloudPHAssetImage: Driver<Bool>
    }
    
    // MARK: - properties
    private let albumsManager = AlbumsManager()
    private let photosManager = PhotosManager()
    private var allPhotosResult: PHFetchResult<PHAsset> = PHFetchResult()
    private var smartAlbumsResult: PHFetchResult<PHAssetCollection> = PHFetchResult()
    private var userCollectionAlbumsResult: PHFetchResult<PHAssetCollection> = PHFetchResult()
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    private let albumSectionsRelay = PublishRelay<[AlbumSection]>()
    
    // MARK: - life cycle
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        input.fetchAlbums
            .subscribe(with: self, onNext: { owner, _ in
                owner.fetchAlbumSections()
            })
            .disposed(by: disposeBag)
        
        input.updateAlbums
            .subscribe(with: self, onNext: { owner, change in
                owner.updateAlbums(with: change)
            })
            .disposed(by: disposeBag)
        
        let photosManagerInput = PhotosManager.Input(fetchImage: input.fetchPHAssetImage)
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        return Output(albums: albumSectionsRelay.asObservable(),
                      phAssetImageprogress: photosManagerOutput.progress,
                      phAssetImage: photosManagerOutput.image,
                      checkiCloudPHAssetImage: photosManagerOutput.checkiCloudPHAssetImage)
    }
    
    /// PhotosManager를 통해 앨범 리스트를 가져옵니다
    private func fetchAlbumSections() {
        let albumSections = [AlbumSection(type: .allPhotos, items: fetchAlbums(with: .allPhotos)),
                             AlbumSection(type: .smartAlbums, items: fetchAlbums(with: .smartAlbums)),
                             AlbumSection(type: .userCollections, items: fetchAlbums(with: .userCollections))
        ]
        
        albumSectionsRelay.accept(albumSections)
    }
    
    /// 앨범 타입에 따른 앨범 리스트를 가져옵니다
    private func fetchAlbums(with type: AlbumType) -> [Album] {
        switch type {
        case .allPhotos:
            allPhotosResult = albumsManager.fetchAllPhotos()
            return [
                Album(type: .allPhotos,
                      phFetchResult: allPhotosResult,
                      title: "All Photos")
            ]
        case .smartAlbums:
            smartAlbumsResult = albumsManager.fetchAlbums(with: .smartAlbum)
            return albums(with: .smartAlbums, result: smartAlbumsResult)
        case .userCollections:
            userCollectionAlbumsResult = albumsManager.fetchAlbums(with: .album)
            return albums(with: .userCollections, result: userCollectionAlbumsResult)
        }
    }
    
    private func albums(with type: AlbumType, result: PHFetchResult<PHAssetCollection>) -> [Album] {
        let collectionType: PHAssetCollectionType = {
            if type == .smartAlbums {
                return .smartAlbum
            } else {
                return .album // user collection
            }
        }()
        
        let fetchingResult = albumsManager.fetchAlbums(with: collectionType)
        
        var albums: [Album] = []
        fetchingResult.enumerateObjects { collection, index, _ in
            let phFetchResult = self.albumsManager.fetchPhotos(in: collection)
            
            if phFetchResult.count == 0 {
                return
            }

            albums.append(
                Album(type: .smartAlbums,
                      phAssetCollection: collection,
                      phFetchResult: phFetchResult,
                      title: collection.localizedTitle ?? "")
            )
        }
        
        return albums
    }
    
    /// 기기에 사진이 추가되거나 삭제 되는 등의 업데이트가 생겼을 때 반영합니다.
    private func updateAlbums(with changeInstance: PHChange) {
        // allPhotos
        if let changeDetails = changeInstance.changeDetails(for: allPhotosResult) {
            allPhotosResult = changeDetails.fetchResultAfterChanges
        }
        
        // smartAlbums
        if let changeDetails = changeInstance.changeDetails(for: smartAlbumsResult) {
            smartAlbumsResult = changeDetails.fetchResultAfterChanges
        }
        
        // userCollections
        if let changeDetails = changeInstance.changeDetails(for: userCollectionAlbumsResult) {
            userCollectionAlbumsResult = changeDetails.fetchResultAfterChanges
        }
        
        let allPhotosAlbum = Album(type: .allPhotos,
                                  phFetchResult: allPhotosResult,
                                  title: "All Photos")
        
        let albumSections = [AlbumSection(type: .allPhotos, items: [allPhotosAlbum]),
                             AlbumSection(type: .smartAlbums, items: albums(with: .smartAlbums, result: smartAlbumsResult)),
                             AlbumSection(type: .userCollections, items: albums(with: .userCollections, result: userCollectionAlbumsResult))
        ]
        
        albumSectionsRelay.accept(albumSections)
    }
}
