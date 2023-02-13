//
//  Album.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import Foundation
import Photos
import RxDataSources

struct Album: Equatable, IdentifiableType {
    var type: AlbumType
    var phAssetCollection: PHAssetCollection?
    var phFetchResult: PHFetchResult<PHAsset>
    var title: String
    let identity: String
    
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
