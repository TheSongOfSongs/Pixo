//
//  OverlayImageViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit
import Photos

import FirebaseStorage
import Kingfisher
import RxCocoa
import RxDataSources
import RxSwift

class OverlayImageViewController: UIViewController {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<SVGImageSection>
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    let viewModel = OverlayImageViewModel()
    lazy var sectionInsets = UIEdgeInsets(top: 32,
                                          left: 40,
                                          bottom: 39 + UIApplication.safeAreaBottomInset,
                                          right: 40)
    let padding: CGFloat = 16
    let itemsPerColumn: CGFloat = 1
    var phAsset: PHAsset?
    let saveImageSubject = PublishSubject<UIImage>()
    let urlCacheManager = URLCacheManager.shared
    var phAssetImage: UIImage?
    var fetchPHAssetImageSubject = PublishSubject<(PHAsset, CGSize)>()
    
    var dataSource: DataSource {
        return DataSource(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                                for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            Task {
                await cell.imageView.setSVGImage(with: item)
            }
            
            return cell
        })
    }
    
    var overlayImageViews: [UIImageView] = []
    
    // MARK: Properties - UI
    let topView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "close"), for: .normal)
    }
    
    let overlayButton = UIButton().then {
        $0.titleLabel?.font = .button
        $0.makeCornerRounded(radius: 16)
        $0.isHidden = true
        $0.tintColor = UIColor(r: 255, g: 251, b: 230)
        $0.backgroundColor = .black
        $0.setTitle("Overlay", for: .normal)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout().then {
            $0.sectionInset = self.sectionInsets
            $0.scrollDirection = .horizontal
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
            $0.showsHorizontalScrollIndicator = false
        }
        return collectionView
    }()
    
    let phAssetImageBackgroundView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let phAssetImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    var svgImageView = IdentifiableImageView(frame: .zero)
    
    // MARK: - view lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
        
        phAssetImageView.image = phAssetImage
    }
    
    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor =  UIColor(r: 250, g: 249, b: 246)
        }
        
        self.view = view
    }
    
    // MARK: -
    func bind() {
        // 현재 데이터를 추가로딩하는 중인지 판별하는 flag 값
        var isFetchingMore = false
        
        let mergeAndExportImage = PublishSubject<ImageMergingSources>()
        
        // viewModel
        let fetchSVGImageSections = PublishSubject<Void>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable(),
                                                saveToAlbum: saveImageSubject.asObservable(),
                                                mergeAndExportImage: mergeAndExportImage.asObservable())
        
        let output = viewModel.transform(input: input)
        
        let svgImageSections = output.svgImageSections
            .share()
        
        svgImageSections
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        svgImageSections
            .subscribe(onNext: { _ in
                isFetchingMore = false
            })
            .disposed(by: disposeBag)
        
        output.noMoreImages
            .subscribe(with: self, onNext: { owner, _ in
                fetchSVGImageSections.onCompleted()
            })
            .disposed(by: disposeBag)
        
        output.alert
            .drive(with: self, onNext: { owner, type in
                owner.showAlertController(with: type)
            })
            .disposed(by: disposeBag)
        
        fetchSVGImageSections.onNext(())
        
        // UI event
        closeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        // 오버레이 버튼 눌렀을 때
        overlayButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                guard let phAsset = owner.phAsset else { return }
                // 이미지 합성 및 추출, 앨범 저장 요청
                let sources = ImageMergingSources(phAsset: phAsset,
                                                  backgroundImageView: owner.phAssetImageView,
                                                  overlayImageViews: owner.overlayImageViews)
                mergeAndExportImage.onNext(sources)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(SVGImage.self)
            .bind(with: self, onNext: { owner, item in
                owner.overlayButton.isHidden = false
                owner.addSVGImageView(item)
            })
            .disposed(by: disposeBag)
        
        // 스크롤 끝에 닿기 전에 데이터 추가 요청
        Observable.combineLatest(svgImageSections, collectionView.rx.didScroll)
            .filter({ _ in !isFetchingMore })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                let offsetX = owner.collectionView.contentOffset.x
                let contentWidth = owner.collectionView.contentSize.width
                
                if offsetX > contentWidth - owner.collectionView.frame.size.width - 50 {
                    fetchSVGImageSections.onNext(())
                    isFetchingMore = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// SVGImage로부터 이미지를 저장소에서 다운받아 UIImageView를 생성하여
    /// phAssetImageView에 추가해줍니다.
    func addSVGImageView(_ svgImage: SVGImage) {
        // svg 이미지를 추가하기 전, 이전 추가된 이미지는 삭제
        overlayImageViews.forEach { overlayImageView in
            overlayImageView.removeFromSuperview()
            overlayImageViews.removeAll(where: { $0 === overlayImageView })
        }
        
        let svgImageView = IdentifiableImageView(frame: .zero).then {
            $0.contentMode = .scaleAspectFit
        }
        
        Task {
            // 이미지를 가져와 넣어주기
            await svgImageView.setSVGImage(with: svgImage)
            
            // 가져온 이미지의 사이즈를 바탕으로 frame 정해주기
            let imageBounds = phAssetImageView.imageBounds
            let width = min(imageBounds.width * 0.8, imageBounds.height * 0.8)
            svgImageView.setFrame(with: phAssetImageView.center,
                               size: CGSize(width: width, height: width))
        }
        
        phAssetImageView.addSubview(svgImageView)
        overlayImageViews.append(svgImageView)
    }
}
