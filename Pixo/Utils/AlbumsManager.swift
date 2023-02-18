//
//  PhotosManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos

/// 앨범 리스트를 가져오기 위해 만들어진 클래스입니다.
final class AlbumsManager {
    
    // 최신순으로 사진만 가져오는 옵션
    let imageFetchingOptions = PHFetchOptions().then {
        $0.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        $0.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
    }
    
    // MARK: -
    /// 모든 사진을 가져옵니다.
    func fetchAllPhotos() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: imageFetchingOptions)
    }
    
    /// 앨범 타입에 따른 앨범리스트를 가져옵니다.
    func fetchAlbums(with type: PHAssetCollectionType) -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: type,
                                                       subtype: .albumRegular,
                                                       options: nil)
    }
    
    /// 앨범의 사진 리스트를 가져옵니다.
    func fetchPhotos(in collection: PHAssetCollection) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: imageFetchingOptions)
    }
}

