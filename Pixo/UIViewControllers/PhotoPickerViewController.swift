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
    
    // tableView
    let fetchAlbumsSubject = PublishSubject<Void>()
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    
    // collectionView
    private let selectedAlbumRelay = BehaviorRelay<Album>(value: Album(type: .allPhotos,
                                                                       phFetchResult: PHFetchResult(),
                                                                        title: ""))
    var selectedAlbumPHAsset: PHFetchResult<PHAsset> {
        return selectedAlbumRelay.value.phFetchResult
    }
    let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let padding: CGFloat = 8
    let itemsPerRow: CGFloat = 3
    var photoPreviewSize: CGSize {
        let paddingSpace = sectionInsets.left * 2 + padding * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let width = availableWidth / itemsPerRow
        return CGSize(width: width, height: width)
    }
    
    
    // MARK: Properties - UI
    let titleView = PhotoPickerTitleView(frame: .zero)
    
    let tableView = UITableView().then {
        $0.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.identifier)
        $0.rowHeight = 85
        $0.separatorStyle = .none
        $0.isHidden = true
    }
    
    lazy var photoCollectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = self.sectionInsets
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        }
        return collectionView
    }()
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCollectionView()
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
    func setupCollectionView() {
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    func bind() {
        // titleView
        titleView.photoPickerDriver
            .drive(with: self, onNext: { owner, photoPicker in
                switch photoPicker {
                case .photos:
                    owner.tableView.setHiddenWithAnimation(true)
                    owner.photoCollectionView.setHiddenWithAnimation(false)
                case .albums:
                    owner.tableView.setHiddenWithAnimation(false)
                    owner.photoCollectionView.setHiddenWithAnimation(true)
                }
            })
            .disposed(by: disposeBag)
        
        // tableView
        Observable.zip(tableView.rx.modelSelected(Album.self), tableView.rx.itemSelected)
            .map({ $0.0 })
            .bind(with: self, onNext: { owner, album in
                owner.selectedAlbumRelay.accept(album)
                owner.titleView.photoPickerRelay.accept(.photos)
            })
            .disposed(by: disposeBag)
        
        // collectionView
        // BehaviorRelay 초기값 허수로 지정했기 때문에 skip
        selectedAlbumRelay
            .skip(1)
            .bind(with: self, onNext: { owner, album in
                owner.photoCollectionView.reloadData()
                owner.titleView.titleLabel.text = album.title
            })
            .disposed(by: disposeBag)
        
        let input = PhotoPickerViewModel.Input(fetchAlbums: fetchAlbumsSubject.asObservable())
        let output = viewModel.transform(input: input)
        
        // output
        let albums = output.albums
            .share()
        
        albums
            .bind(to: tableView.rx.items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
        
        // collection view의 default 아이템을 위해 위해 앨범 리스트 중 가장 첫번째 것을 선택하여 보여줌
        // 1회만 실행
        albums
            .take(1)
            .compactMap({ $0.first?.items.first })
            .bind(with: self, onNext: { owner, album in
                owner.selectedAlbumRelay.accept(album)
            })
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
