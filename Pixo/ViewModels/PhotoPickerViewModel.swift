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

class PhotoPickerViewModel: ViewModel {
    
    struct Input {
        var fetchAlbums: Observable<Void>
        let fetchPHAssetImage: Observable<(PHAsset, CGSize)>
    }
    
    struct Output {
        var albums: Observable<[AlbumSection]>
        let phAssetImageprogress: Driver<Double>
        let phAssetImage: Driver<UIImage?>
        let checkiCloudPHAssetImage: Driver<Bool>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    
    private let albumsManager = AlbumsManager()
    private let photosManager = PhotosManager()
    
    private let albumSectionsRelay = PublishRelay<[AlbumSection]>()
    
    private var allPhotosResult: PHFetchResult<PHAsset> = PHFetchResult()
    private var smartAlbumsResult: PHFetchResult<PHAssetCollection> = PHFetchResult()
    private var userCollectionAlbumsResult: PHFetchResult<PHAssetCollection> = PHFetchResult()
    
    
    // MARK: -
    func transform(input: Input) -> Output {
        input.fetchAlbums
            .subscribe(with: self, onNext: { owner, _ in
                owner.fetchAlbumSections()
            })
            .disposed(by: disposeBag)
        
        let photosManagerInput = PhotosManager.Input(requestImage: input.fetchPHAssetImage)
        let photosManagerOutput = photosManager.transform(input: photosManagerInput)
        
        return Output(albums: albumSectionsRelay.asObservable(),
                      phAssetImageprogress: photosManagerOutput.progress,
                      phAssetImage: photosManagerOutput.image,
                      checkiCloudPHAssetImage: photosManagerOutput.checkiCloudPHAssetImage)
    }
    
    /// PhotosManager를 통해 앨범 리스트를 가져옵니다
    func fetchAlbumSections() {
        let albumSections = [AlbumSection(type: .allPhotos, items: fetchAlbums(with: .allPhotos)),
                             AlbumSection(type: .smartAlbums, items: fetchAlbums(with: .smartAlbums)),
                             AlbumSection(type: .userCollections, items: fetchAlbums(with: .userCollections))
        ]
        
        albumSectionsRelay.accept(albumSections)
    }
    
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
    
    func updateAlbums(with changeInstance: PHChange) {
        // allPhotos
        if let changeDetails = changeInstance.changeDetails(for: allPhotosResult) {
            allPhotosResult = changeDetails.fetchResultAfterChanges
        }
        
        // smartAlbums
        if let changeDetails = changeInstance.changeDetails(for: smartAlbumsResult) {
            smartAlbumsResult = changeDetails.fetchResultAfterChanges
        }
        
        // userCollections// smartAlbums
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
