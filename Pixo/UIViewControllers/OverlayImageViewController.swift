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
                                          bottom: 39 + safeAreaBottomInsets,
                                          right: 40)
    let padding: CGFloat = 16
    let itemsPerColumn: CGFloat = 1
    var phAsset: PHAsset?
    var safeAreaBottomInsets: CGFloat = UIApplication.safeAreaInsets?.bottom ?? 0
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
        
        // viewModel
        let fetchSVGImageSections = PublishSubject<Void>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable(),
                                                saveToAlbum: saveImageSubject.asObservable(),
                                                fetchPHAssetImage: fetchPHAssetImageSubject.asObservable())
        
        let output = viewModel.transform(input: input)
        
        let svgImageSections = output.svgImageSections
            .share()
        
        let phAssetImage = output.phAssetImage
        
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
                // PHAsset 이미지 원본 사이즈 요청
                owner.fetchPHAssetImageSubject.onNext((phAsset,
                                                       CGSize(width: phAsset.pixelWidth,
                                                              height: phAsset.pixelHeight)))
            })
            .disposed(by: disposeBag)
        
        // PHAsset 이미지 원본 사이즈 받았을 때
        phAssetImage
            .drive(with: self, onNext: { owner, phAssetImage in
                guard let phAsset = owner.phAsset,
                      let phAssetImage = phAssetImage,
                      let svgImage = owner.svgImageView.image else {
                    return
                }
                
                // 이미지 합성
                // 이미지 합성 (1) - PHAsset 이미지 그리기
                let phAssetImageSize = CGSize(width: phAsset.pixelWidth, height: phAsset.pixelHeight)
                UIGraphicsBeginImageContextWithOptions(phAssetImageSize, true, 1)
                phAssetImage.draw(at: .zero)
                
                
                // 이미지 합성 (2) - SVG 이미지 그리기
                svgImage.draw(in: owner.svgImageRect(to: phAssetImageSize))
                
                // 앨범에 저장
                if let result = UIGraphicsGetImageFromCurrentImageContext() {
                    owner.saveImageSubject.onNext(result)
                }
                
                UIGraphicsEndImageContext()
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
        phAssetImageView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        svgImageView = IdentifiableImageView(frame: .zero).then {
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
    }
    
    /// 이미지 합성 시, 원본 이미지와 PHAssetImageView의 비율을 고려한 SVG 이미지의 frame을 반환합니다.
    func svgImageRect(to phAssetImageSize: CGSize) -> CGRect {
        let svgImageViewFrame = svgImageView.frame
        let phAssetImageBounds = phAssetImageView.imageBounds
        let origin: CGPoint = {
            return CGPoint(x: phAssetImageSize.width * (svgImageViewFrame.origin.x - phAssetImageBounds.origin.x) / phAssetImageBounds.width,
                           y: phAssetImageSize.height * (svgImageViewFrame.origin.y - phAssetImageBounds.origin.y) / phAssetImageBounds.height)
        }()
        
        let width = svgImageViewFrame.width * phAssetImageSize.width / phAssetImageBounds.width
        let size = CGSize(width: width, height: width) // 이미지 비율 1:1
        return CGRect(origin: origin, size: size)
    }
}
