//
//  Album.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import Foundation
import Photos
import RxDataSources

/// 사용자 앨범 리스트에서 가져온 앨범을 collection view에서 쓰일 수 있도록 가공한 타입입니다.
struct Album: Equatable, IdentifiableType {
    var type: AlbumType
    var title: String
    let identity: String
    
    /// 해당 앨범이 속한 Collection 정보를 담고 있습니다. type이 AllPhotos일 경우, nil입니다.
    var phAssetCollection: PHAssetCollection?
    
    /// 앨범의 사진 정보를 담고 있습니다.
    var phFetchResult: PHFetchResult<PHAsset>
    
    var previewPHAsset: PHAsset? {
        return phFetchResult.firstObject
    }
    
    init(type: AlbumType, phAssetCollection: PHAssetCollection? = nil, phFetchResult: PHFetchResult<PHAsset>, title: String) {
        self.type = type
        self.phAssetCollection = phAssetCollection
        self.phFetchResult = phFetchResult
        self.title = title
        self.identity = "\(type) \(title)"
    }
}
