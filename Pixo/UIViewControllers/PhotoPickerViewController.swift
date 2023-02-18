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
    
    /// 현재 선택된 앨범 정보와 collection view를 리로드해야하는지 여부를 나타냅니다.
    /// 선택된 album이 바뀔 때마다 relay에 값을 넣어주면 구독하는 쪽의 코드에서  collection view를 항상 reload 시킵니다.
    /// album 값이 변경되면 collection view의 데이터소스는 업데이트되어야 하지만, collection view를 reload하는게 아니라
    /// 변경된 부분만 업데이트시켜줘야 하므로 reload 여부를 Bool 값으로 전달합니다.
    typealias AlbumDataSource = (album: Album, shouldReload: Bool)
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    let viewModel = PhotoPickerViewModel()
    
    // tableView
    let fetchAlbumsSubject = PublishSubject<Void>()
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    let albumSectionsRelay = BehaviorRelay<[AlbumSection]>(value: [])
    var albumSections: [AlbumSection] {
        return albumSectionsRelay.value
    }
    
    // collectionView
    let selectedAlbumRelay = BehaviorRelay<(Album, Bool)>(value: (Album(type: .allPhotos,
                                                                        phFetchResult: PHFetchResult(),
                                                                        title: ""),
                                                                  false))
    let pushOverlayImageViewControllerSubject = PublishSubject<(PHAsset, CGSize)>()
    
    var selectedAlbum: Album {
        return selectedAlbumRelay.value.0
    }
    var selectedAlbumPHAsset: PHFetchResult<PHAsset> {
        return selectedAlbum.phFetchResult
    }
    
    var phAsset: PHAsset?
    
    let sectionInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let padding: CGFloat = 8
    let itemsPerRow: CGFloat = 3
    
    lazy var collectionViewCellSize: CGSize = {
        let paddingSpace = sectionInsets.left * 2 + padding * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let width = availableWidth / itemsPerRow
        return CGSize(width: width, height: width)
    }()
    
    var photoPreviewSize: CGSize {
        let scale = UIScreen.main.scale
        let width = collectionViewCellSize.width * scale
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
        fetchAlbumsSubject.onNext(())
        PHPhotoLibrary.shared().register(self)
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
                owner.selectedAlbumRelay.accept((album, true))
                owner.titleView.photoPickerRelay.accept(.photos)
            })
            .disposed(by: disposeBag)
        
        // collectionView
        // BehaviorRelay 초기값 허수로 지정했기 때문에 skip
        selectedAlbumRelay
            .skip(1)
            .filter({ $0.1 })
            .map({ $0.0 })
            .bind(with: self, onNext: { owner, album in
                owner.photoCollectionView.reloadData()
                owner.titleView.titleLabel.text = album.title
            })
            .disposed(by: disposeBag)
        
        let input = PhotoPickerViewModel.Input(fetchAlbums: fetchAlbumsSubject.asObservable(),
                                               fetchPHAssetImage: pushOverlayImageViewControllerSubject.asObservable())
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
                owner.selectedAlbumRelay.accept((album: album, shouldReload: true))
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
        
        output.phAssetImage
            .drive(with: self, onNext: { owner, image in
                // progressCircleView 숨기기
                if !owner.progressCircleView.isHidden {
                    usleep(200000) // 애니메이션 마무리되는 0.2초 동안 기다리기
                    owner.view.isUserInteractionEnabled = true
                    owner.progressCircleView.isHidden = true
                }
                
                // 화면 전환
                let overlayImageVC = OverlayImageViewController()
                overlayImageVC.phAsset = owner.phAsset
                overlayImageVC.phAssetImage = image
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
