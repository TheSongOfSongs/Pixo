//
//  PhotosManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos

/// 앨범에서 사진을 가져오는 기능을 하기 위해 만들어진 클래스입니다
final class PhotosManager {
    
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

