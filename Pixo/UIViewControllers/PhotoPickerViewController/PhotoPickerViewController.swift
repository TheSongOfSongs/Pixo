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
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    let fetchAlbums = PublishSubject<Void>()
    let albumSections = BehaviorRelay<[AlbumSection]>(value: [])
    let albumDataSource = BehaviorRelay<AlbumDataSource>(value: (album: Album(type: .allPhotos,
                                                                              phFetchResult: PHFetchResult(),
                                                                              title: ""),
                                                                 shouldReload: false))
    let pushOverlayImageViewController = PublishSubject<FetchingPHAssetImageSource>()
    let selectedPHAsset = PublishSubject<PHAsset>()
    let updateAlbums = PublishSubject<PHChange>()
    
    var tableViewDataSource: RxTableViewSectionedReloadDataSource<AlbumSection> {
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
    
    // MARK: - properties
    let viewModel = PhotoPickerViewModel()
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let padding: CGFloat = 8
    let itemsPerRow: CGFloat = 3
    
    /// ?????? ???????????? ?????? ???????????? ????????? ??????
    var selectedAlbum: Album {
        return albumDataSource.value.album
    }
    
    /// ?????? ????????? ?????? ?????????. collection view??? dataSource
    var selectedAlbumPHAsset: PHFetchResult<PHAsset> {
        return selectedAlbum.phFetchResult
    }
    
    lazy var photoCollectionViewCellSize: CGSize = {
        let paddingSpace = sectionInsets.left * 2 + padding * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let width = availableWidth / itemsPerRow
        return CGSize(width: width, height: width)
    }()
    
    var photoPreviewSize: CGSize {
        let scale = UIScreen.main.scale
        let width = photoCollectionViewCellSize.width * scale
        return CGSize(width: width, height: width)
    }
    
    // MARK: - properties UI
    let titleView = PhotoPickerTitleView(frame: .zero)
    
    let albumTableView = UITableView().then {
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
    
    /// iCloud ?????? ??????????????? ???????????? ???
    let progressCircleView = ProgressCircleView(frame: .zero,
                                                title: "iCloud?????? ?????? ???").then {
        $0.isHidden = true
    }
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCollectionView()
        bind()
        fetchAlbums.onNext(())
        PHPhotoLibrary.shared().register(self)
    }
    
    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    
    // MARK: - helpers
    func setupCollectionView() {
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    func bind() {
        let input = PhotoPickerViewModel.Input(fetchAlbums: fetchAlbums.asObservable(),
                                               fetchPHAssetImage: pushOverlayImageViewController.asObservable(),
                                               updateAlbums: updateAlbums.asObservable())
        
        let output = viewModel.transform(input: input)
        
        let albums = output
            .albums
            .share()
        
        titleView.photoPicker
            .drive(with: self, onNext: { owner, photoPicker in
                switch photoPicker {
                case .photos:
                    owner.albumTableView.setHiddenWithAnimation(true)
                    owner.photoCollectionView.setHiddenWithAnimation(false)
                case .albums:
                    owner.albumTableView.setHiddenWithAnimation(false)
                    owner.photoCollectionView.setHiddenWithAnimation(true)
                }
            })
            .disposed(by: disposeBag)
        
        // tableView
        Observable.zip(albumTableView.rx.modelSelected(Album.self), albumTableView.rx.itemSelected)
            .map({ $0.0 })
            .bind(with: self, onNext: { owner, album in
                owner.albumDataSource.accept((album, true))
                owner.titleView.setPhotoPicker.accept(.photos)
            })
            .disposed(by: disposeBag)
        
        // collectionView
        // BehaviorRelay ????????? ????????? ???????????? ????????? skip
        albumDataSource
            .skip(1)
            .filter({ $0.shouldReload })
            .map({ $0.album })
            .bind(with: self, onNext: { owner, album in
                owner.photoCollectionView.reloadData()
                owner.titleView.titleLabel.text = album.title
            })
            .disposed(by: disposeBag)
        
        albums
            .bind(to: albumTableView.rx.items(dataSource: tableViewDataSource))
            .disposed(by: disposeBag)
        
        // collection view??? default ???????????? ?????? ?????? ?????? ????????? ??? ?????? ????????? ?????? ???????????? ?????????
        // 1?????? ??????
        albums
            .take(1)
            .compactMap({ $0.first?.items.first })
            .bind(with: self, onNext: { owner, album in
                owner.albumDataSource.accept((album: album, shouldReload: true))
            })
            .disposed(by: disposeBag)
        
        // iCloud?????? progress ???????????? ??? ??????
        output.checkiCloudPHAssetImage
            .filter({ $0 })
            .drive(with: self, onNext: { owner, isICloud in
                owner.view.isUserInteractionEnabled = false
                owner.progressCircleView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        output.phAssetImageprogress
            .drive(with: self, onNext: { owner, progress in
                owner.progressCircleView
                    .progress
                    .accept(progress)
            })
            .disposed(by: disposeBag)
        
        // ???????????? ????????? ????????????, OverlayImageVC??? ????????? ????????? ????????? ???
        Observable.zip(selectedPHAsset, output.phAssetImage.asObservable())
            .bind(with: self, onNext: { owner, result in
                // progressCircleView ?????????
                if !owner.progressCircleView.isHidden {
                    usleep(200000) // ??????????????? ??????????????? 0.2??? ?????? ????????????
                    owner.view.isUserInteractionEnabled = true
                    owner.progressCircleView.isHidden = true
                }
                
                guard let phAssetImage = result.1 else {
                    owner.showAlertController(with: .failToLoadPhoto)
                    return
                }
                
                // ?????? ??????
                let overlayImageVC = OverlayImageViewController(phAsset: result.0, phAssetImage: phAssetImage)
                owner.navigationController?.pushViewController(overlayImageVC, animated: false)
            })
            .disposed(by: disposeBag)
    }
}
