//
//  PhotoPickerViewController+PHPhotoLibraryChangeObserver.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/12.
//

import UIKit
import Photos

extension PhotoPickerViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: selectedAlbumPHAsset) else {
            return
        }
        
        DispatchQueue.main.sync {
            updateCollectionView(changes: changes)
        }
    }
    
    func updateCollectionView(changes: PHFetchResultChangeDetails<PHAsset>) {
        let album: Album = {
            var album = selectedAlbumRelay.value.0
            album.phFetchResult = changes.fetchResultAfterChanges
            return album
        }()
        
        selectedAlbumRelay.accept((album, false))
        
        guard changes.hasIncrementalChanges else {
            photoCollectionView.reloadData()
            tableView.reloadData()
            return
        }
        
        photoCollectionView.performBatchUpdates {
            if let removed = changes.removedIndexes,
               !removed.isEmpty {
                photoCollectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
            }
            
            if let inserted = changes.insertedIndexes,
               !inserted.isEmpty {
                photoCollectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
            }
            
            changes.enumerateMoves { fromIndex, toIndex in
                self.photoCollectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                  to: IndexPath(item: toIndex, section: 0))
            }
        }
        
        if let changed = changes.changedIndexes,
           !changed.isEmpty {
            photoCollectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
        }
    }
}
