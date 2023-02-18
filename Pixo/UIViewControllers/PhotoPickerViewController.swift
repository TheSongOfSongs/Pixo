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
    
    // MARK: - properties
    let viewModel = PhotoPickerViewModel()
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let padding: CGFloat = 8
    let itemsPerRow: CGFloat = 3
    
    /// 현재 선택되어 사진 리스트가 띄어진 앨범
    var selectedAlbum: Album {
        return albumDataSource.value.album
    }
    
    /// 현재 선택된 앨범 리스트. collection view의 dataSource
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
    
    /// iCloud 로딩 진행상태를 나타내는 뷰
    let progressCircleView = ProgressCircleView(frame: .zero,
                                                title: "iCloud에서 로딩 중").then {
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
        
        titleView.photoPickerDriver
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
                owner.titleView.photoPickerRelay.accept(.photos)
            })
            .disposed(by: disposeBag)
        
        // collectionView
        // BehaviorRelay 초기값 허수로 지정했기 때문에 skip
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
            .bind(to: albumTableView.rx.items(dataSource: tableViewDataSource()))
            .disposed(by: disposeBag)
        
        // collection view의 default 아이템을 위해 위해 앨범 리스트 중 가장 첫번째 것을 선택하여 보여줌
        // 1회만 실행
        albums
            .take(1)
            .compactMap({ $0.first?.items.first })
            .bind(with: self, onNext: { owner, album in
                owner.albumDataSource.accept((album: album, shouldReload: true))
            })
            .disposed(by: disposeBag)
        
        // iCloud이면 progress 보여주는 뷰 세팅
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
        
        // 앨범에서 사진을 선택하고, OverlayImageVC에 넘겨줄 사진을 받았을 때
        Observable.zip(selectedPHAsset, output.phAssetImage.asObservable())
            .bind(with: self, onNext: { owner, result in
                // progressCircleView 숨기기
                if !owner.progressCircleView.isHidden {
                    usleep(200000) // 애니메이션 마무리되는 0.2초 동안 기다리기
                    owner.view.isUserInteractionEnabled = true
                    owner.progressCircleView.isHidden = true
                }
                
                guard let phAssetImage = result.1 else {
                    owner.showAlertController(with: .failToLoadPhoto)
                    return
                }
                
                // 화면 전환
                let overlayImageVC = OverlayImageViewController(phAsset: result.0, phAssetImage: phAssetImage)
                self.navigationController?.pushViewController(overlayImageVC, animated: false)
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
