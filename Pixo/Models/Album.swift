//
//  Album.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import Foundation
import Photos

struct Album {
    var type: AlbumType
    var phFetchResult: PHFetchResult<PHAsset>
    var title: String
    
    var previewPHAsset: PHAsset? {
        return phFetchResult.firstObject
    }
}
