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
        var albums: Observable<[AlbumSection]>
    }
    
    // MARK: properties
    var disposeBag = DisposeBag()
    
    private let photosManager = PhotosManager()
    private let albumsRelay = PublishRelay<[Album]>()
    
    
    // MARK: -
    func transform(input: Input) -> Output {
        input.fetchAlbums
            .subscribe(with: self, onNext: { owner, _ in
                owner.fetchAlbums()
            })
            .disposed(by: disposeBag)
        
        let albums = albumsRelay
            .map {
                return [AlbumSection(header: "", items: $0)]
            }
        
        return Output(albums: albums)
    }
    
    /// PhotosManager를 통해 앨범 리스트를 가져옵니다
    func fetchAlbums() {
        let albums = [photosManager.fetchAllPhotosAlbum()]
        + photosManager.fetchSmartAlbums()
        + photosManager.fetchUserCollectionAlbums()
        
        albumsRelay.accept(albums)
    }
}
