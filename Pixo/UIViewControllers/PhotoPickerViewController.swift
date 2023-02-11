//
//  PhotoPickerViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos

import RxCocoa
import RxDataSources
import RxSwift

class PhotoPickerViewController: UIViewController {
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    let viewModel = PhotoPickerViewModel()
    var fetchAlbumsSubject = PublishSubject<Void>()
    var allPhotos: Album?
    var smartAlbums: [Album] = []
    var userCollections: [Album] = []
    var albums: [Album] = []
    
    // cell previewImage
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    
    
    // MARK: Properties - UI
    let titleView = PhotoPickerTitleView(frame: .zero)
    
    let tableView = UITableView().then {
        $0.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.identifier)
        $0.rowHeight = 85
        $0.separatorStyle = .none
    }
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
        fetchAlbumsSubject.onNext(())
    }

    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    
    // MARK: -
    func bind() {
        // titleView
        titleView.photoPickerObservable
            .bind(with: self, onNext: { owner, photoPicker in
                // TODO: 사진/앨범 리스트 보여주기
                print("💖 \(photoPicker)")
            })
            .disposed(by: disposeBag)
        
        // tableView
        Observable.zip(tableView.rx.modelSelected(Album.self), tableView.rx.modelSelected(Album.self))
            .bind(with: self, onNext: { owner, result in
                print("🔥", result)
            })
            .disposed(by: disposeBag)
        
        let input = PhotoPickerViewModel.Input(fetchAlbums: fetchAlbumsSubject.asObservable())
        let output = viewModel.transform(input: input)
        
        // output
        output.albums
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
    }
    
    func tableViewDataSource() -> RxTableViewSectionedReloadDataSource<AlbumSection> {
        return RxTableViewSectionedReloadDataSource<AlbumSection>(configureCell: { [weak self] _, tableView, indexPath, album in
            guard let self = self,
                  let cell = tableView
                    .dequeueReusableCell(withIdentifier: AlbumTableViewCell.identifier, for: indexPath) as? AlbumTableViewCell else {
                        return UITableViewCell()
                    }
            
            cell.titleLabel.text = album.title
            
            if let previewAsset = album.previewPHAsset {
                self.imageManager.requestImage(for: previewAsset, targetSize: self.previewSize, contentMode: .aspectFill, options: nil) { image, _ in
                    cell.previewImageView.image = image
                }
            }
            
            return cell
        })
    }
}
