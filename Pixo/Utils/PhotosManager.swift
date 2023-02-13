//
//  PhotosManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos

final class PhotosManager {
    
    typealias Albums = (allPhotos: PHFetchResult<PHAsset>,
                        smartAlbums: PHFetchResult<PHAssetCollection>,
                        userCollections: PHFetchResult<PHCollection>)
    
    // 최신순으로 사진만 가져오는 옵션
    let imageFetchingOptions = PHFetchOptions().then {
        $0.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        $0.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
    }
    
    // MARK: -
    func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: imageFetchingOptions)
    }
    
    func fetchAlbums(with type: PHAssetCollectionType) -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: type,
                                                       subtype: .albumRegular,
                                                       options: nil)
    }
    
    func fetchPhotos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: imageFetchingOptions)
    }
}

