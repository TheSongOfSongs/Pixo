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
        // 백그라운드에서 호출되므로 메인쓰레드 실행 필요
        DispatchQueue.main.sync {
            if let changes = changeInstance.changeDetails(for: selectedAlbumPHAsset) {
                // 선택된 앨범의 사진 리스트 업데이트
                updateCollectionView(changes: changes)
            }
        }
        
        // 앨범 리스트 업데이트
        updateAlbums.onNext(changeInstance)
    }
    
    func updateCollectionView(changes: PHFetchResultChangeDetails<PHAsset>) {
        let album: Album = {
            var album = selectedAlbum
            album.phFetchResult = changes.fetchResultAfterChanges
            return album
        }()
        
        albumDataSource.accept((album, false))
        
        guard changes.hasIncrementalChanges else {
            photoCollectionView.reloadData()
            albumTableView.reloadData()
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
