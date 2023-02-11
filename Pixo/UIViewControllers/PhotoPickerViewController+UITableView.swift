//
//  PhotoPickerViewController+UITableView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import UIKit

// MARK: - UITableViewDataSource
extension PhotoPickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return AlbumSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AlbumSection(rawValue: section)! {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier, for: indexPath) as? AlbumTableViewCell else {
            return UITableViewCell()
        }
        
        guard let album: Album = {
            let albumSection = AlbumSection(rawValue: indexPath.section) ?? AlbumSection.allPhotos
            switch albumSection {
            case .allPhotos:
                return allPhotos
            case .smartAlbums:
                return smartAlbums[indexPath.row]
            case .userCollections:
                return userCollections[indexPath.row]
            }
        }() else {
            return cell
        }
        
        cell.titleLabel.text = album.title
        
        if let previewAsset = album.previewPHAsset {
            imageManager.requestImage(for: previewAsset, targetSize: previewSize, contentMode: .aspectFill, options: nil) { image, _ in
                cell.previewImageView.image = image
            }
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension PhotoPickerViewController: UITableViewDelegate { }
