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
    }
    
    struct Output {
        var allPhotos: Observable<Album>
        var smartAlbums: Observable<[Album]>
        var userCollections: Observable<[Album]>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    
    private let photosManager = PhotosManager()
    private let allPhotosRelay = PublishRelay<Album>()
    private let smartAlbumsRelay = PublishRelay<[Album]>()
    private let userCollectionsRelay = PublishRelay<[Album]>()
    
    
    // MARK: -
    func transform(input: Input) -> Output {
        input.fetchAlbums
            .subscribe(with: self, onNext: { owner, _ in
                owner.fetchAlbums()
            })
            .disposed(by: disposeBag)
        
        return Output(allPhotos: allPhotosRelay.asObservable(),
                      smartAlbums: smartAlbumsRelay.asObservable(),
                      userCollections: userCollectionsRelay.asObservable())
    }
    
    func fetchAlbums() {
        fetchAllPhotos()
        fetchSmartAlbums()
        fetchUserCollectionAlbums()
    }
    
    func fetchAllPhotos()  {
        let result = photosManager.fetchAllPhotosAlbum()
        allPhotosRelay.accept(result)
    }
    
    func fetchSmartAlbums() {
        let result = photosManager.fetchSmartAlbums()
        smartAlbumsRelay.accept(result)
    }
    
    func fetchUserCollectionAlbums() {
        let result = photosManager.fetchUserCollectionAlbums()
        userCollectionsRelay.accept(result)
    }
}
