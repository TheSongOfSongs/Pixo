//
//  OverlayImageViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit
import Photos

import FirebaseStorage
import RxCocoa
import RxDataSources
import RxSwift

class OverlayImageViewController: UIViewController {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<SVGImageSection>
    
    // MARK: properties
    let viewModel = OverlayImageViewModel()
    let sectionInsets = UIEdgeInsets(top: 32,
                                     left: 40,
                                     bottom: 39 + UIApplication.safeAreaBottomInset,
                                     right: 40)
    let padding: CGFloat = 16
    let itemsPerColumn: CGFloat = 1
    let phAsset: PHAsset
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    let fetchPHAssetImage = PublishSubject<FetchingPHAssetImageSource>()
    
    /// overlayImageCollectionView dataSource
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
    
    // MARK: - properties UI
    let topView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage.close, for: .normal)
    }
    
    let overlayButton = UIButton().then {
        $0.titleLabel?.font = .button
        $0.makeCornerRounded(radius: 16)
        $0.isHidden = true
        $0.tintColor = UIColor(r: 255, g: 251, b: 230)
        $0.backgroundColor = .black
        $0.setTitle("Overlay", for: .normal)
    }
    
    lazy var overlayImageCollectionView: UICollectionView = {
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
    
    var overlayImageViews: [UIImageView] = []
    
    // MARK: - lifecyle
    init(phAsset: PHAsset, phAssetImage: UIImage) {
        self.phAsset = phAsset
        self.phAssetImageView.image = phAssetImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
    
    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor =  UIColor.beige
        }
        
        self.view = view
    }
    
    // MARK: - helpers
    func bind() {
        /// ?????? ????????? ?????? ????????? ???????????? flag ???
        var isFetchingMore = false
        
        let fetchSVGImageSections = PublishSubject<Void>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable())
        let output = viewModel.transform(input: input)
        let svgImageSections = output
            .svgImageSections
            .share()
        
        svgImageSections
            .bind(to: overlayImageCollectionView.rx.items(dataSource: self.dataSource))
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
        
        closeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        // ???????????? ?????? ????????? ??? > ExportVC??? ??????
        overlayButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                guard let previewImage = owner.mergedImage() else {
                    owner.showAlertController(with: .failToLoadPhoto)
                    return
                }
                
                owner.pushExportViewController(previewImage: previewImage)
            })
            .disposed(by: disposeBag)
        
        overlayImageCollectionView.rx.modelSelected(SVGImage.self)
            .bind(with: self, onNext: { owner, item in
                owner.overlayButton.isHidden = false
                owner.addSVGImageView(item)
            })
            .disposed(by: disposeBag)
        
        // ????????? ?????? ?????? ?????? ????????? ?????? ??????
        Observable.combineLatest(svgImageSections, overlayImageCollectionView.rx.didScroll)
            .observe(on: MainScheduler.instance)
            .filter({ _ in !isFetchingMore })
            .filter({ _ in
                let offsetX = self.overlayImageCollectionView.contentOffset.x
                let contentWidth = self.overlayImageCollectionView.contentSize.width
                return offsetX > contentWidth - self.overlayImageCollectionView.frame.size.width - 50
            })
            .subscribe(onNext: { _ in
                fetchSVGImageSections.onNext(())
                isFetchingMore = true
            })
            .disposed(by: disposeBag)
    }
    
    /// SVGImage????????? ???????????? ??????????????? ???????????? UIImageView??? ???????????? phAssetImageView??? ??????????????????.
    func addSVGImageView(_ svgImage: SVGImage) {
        // svg ???????????? ???????????? ???, ?????? ????????? ???????????? ??????
        overlayImageViews.forEach { overlayImageView in
            overlayImageView.removeFromSuperview()
            overlayImageViews.removeAll(where: { $0 === overlayImageView })
        }
        
        let svgImageView = IdentifiableImageView(frame: .zero).then {
            $0.contentMode = .scaleAspectFit
        }
        
        Task {
            // ???????????? ????????? ????????????
            await svgImageView.setSVGImage(with: svgImage)
            
            // ????????? ???????????? ???????????? ???????????? frame ????????????
            let imageBounds = phAssetImageView.imageBounds
            let width = min(imageBounds.width * 0.8, imageBounds.height * 0.8)
            svgImageView.setFrame(with: phAssetImageView.center,
                                  size: CGSize(width: width, height: width))
        }
        
        phAssetImageView.addSubview(svgImageView)
        overlayImageViews.append(svgImageView)
    }
    
    /// ?????? ????????? ???????????? ?????? ?????? ???????????? ????????? ????????? ???????????? ??????????????? ?????? ????????? ???????????? ???????????????.
    /// ?????????????????? ?????????????????? ExportViewController?????? ???????????? ???????????? ???????????????.
    private func mergedImage() -> UIImage? {
        let imageRect: CGRect = {
            var bounds = phAssetImageView.bounds
            bounds.origin = CGPoint(x: -phAssetImageView.imageBounds.origin.x,
                                    y: -phAssetImageView.imageBounds.origin.y)
            return bounds
        }()
        
        UIGraphicsBeginImageContextWithOptions(phAssetImageView.imageBounds.size, false, 0.0)
        phAssetImageView.drawHierarchy(in: imageRect, afterScreenUpdates: true)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func pushExportViewController(previewImage: UIImage) {
        let sources = ImageMergingSources(phAsset: phAsset,
                                          backgroundImageView: phAssetImageView,
                                          overlayImageViews: overlayImageViews)
        
        let exportViewController = ExportViewController(imageMergingSources: sources,
                                                        previewImage: previewImage)
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.pushViewController(exportViewController, animated: true)
    }
}
