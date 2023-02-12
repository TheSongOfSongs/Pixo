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
    func fetchAllPhotosAlbum() -> Album {
        let allPhotos = PHAsset.fetchAssets(with: imageFetchingOptions)
        return Album(type: .allPhotos,
                     phFetchResult: allPhotos,
                     title: "All Photos")
    }
    
    func fetchSmartAlbums() -> [Album] {
        let fetchingResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                     subtype: .albumRegular,
                                                                     options: nil)
        
        var smartAlbums: [Album] = []
        fetchingResult.enumerateObjects { collection, index, _ in
            let phFetchResult = PHAsset.fetchAssets(in: collection, options: self.imageFetchingOptions)
            
            if phFetchResult.count == 0 {
                return
            }

            smartAlbums.append(
                Album(type: .smartAlbums,
                      phFetchResult: phFetchResult,
                      title: collection.localizedTitle ?? "")
            )
        }
        
        return smartAlbums
    }
    
    func fetchUserCollectionAlbums() -> [Album] {
        let fetchingResult = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                     subtype: .albumRegular,
                                                                     options: nil)
        
        var userCollections: [Album] = []
        fetchingResult.enumerateObjects { collection, index, _ in
            let phFetchResult = PHAsset.fetchAssets(in: collection, options: self.imageFetchingOptions)
            
            if phFetchResult.count == 0 {
                return
            }

            userCollections.append(
                Album(type: .smartAlbums,
                      phFetchResult: phFetchResult,
                      title: collection.localizedTitle ?? "")
            )
        }
        
        return userCollections
    }
}

