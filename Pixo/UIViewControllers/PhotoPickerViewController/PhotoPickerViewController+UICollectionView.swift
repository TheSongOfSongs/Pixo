//
//  PhotoPickerViewController+UICollectionView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import UIKit

// MARK: - UICollectionViewDataSource
extension PhotoPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAlbumPHAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let asset = selectedAlbumPHAsset.object(at: indexPath.row)
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: photoPreviewSize, contentMode: .aspectFill, options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension PhotoPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let asset = selectedAlbumPHAsset[indexPath.row]
         let size: CGSize = {
             // OverlayImageVC의 phAssetImageView 사이즈 기반으로 계산
             let scale = UIScreen.main.scale
             let width = view.frame.width * scale
             let height = (view.frame.height - 80 - 151 - view.safeAreaInsets.bottom) * scale
             return CGSize(width: width, height: height)
         }()
        
        selectedPHAsset.onNext(asset)
        pushOverlayImageViewController.onNext((asset, size))
        
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return photoCollectionViewCellSize
    }
}
