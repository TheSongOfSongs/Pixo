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
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: phAssetImageView.bounds.width * scale,
                      height: phAssetImageView.bounds.height * scale)
    }
    
    var dataSource: DataSource {
        return DataSource(configureCell: { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier,
                                                                for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            Task {
                let url = try await item.downloadURL()
                cell.imageView.setSVGImage(with: url)
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
    
    
    // MARK: - view lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bind()
    }
    
    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor =  UIColor(r: 250, g: 249, b: 246)
        }
        
        self.view = view
    }
    
    // MARK: -
    func bind() {
        guard let phAsset = phAsset else {
            return
        }
        
        // viewModel
        let fetchSVGImageSections = PublishSubject<Void>()
        let requestPHassetImage = PublishSubject<(PHAsset, CGSize)>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable(),
                                                requestPHAssetImage: requestPHassetImage.asObserver(),
                                                saveToAlbum: saveImageSubject.asObserver())
        let output = viewModel.transform(input: input)
        
        output.svgImageSections
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        output.phAssetImageprogress
            .drive(with: self, onNext: { owner, progress in
                // TODO: progress 띄우는 작업
            })
            .disposed(by: disposeBag)
        
        output.phAssetImage
            .drive(with: self, onNext: { owner, image in
                // TODO: progress 숨기기
                owner.phAssetImageView.image = image
            })
            .disposed(by: disposeBag)
        
        output.alert
            .drive(with: self, onNext: { owner, type in
                owner.showAlertController(with: type)
            })
            .disposed(by: disposeBag)
        
        fetchSVGImageSections.onNext(())
        requestPHassetImage.onNext((phAsset, targetSize))
        
        // UI event
        closeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
        
        overlayButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                if let image = owner.exportImage() {
                    owner.saveImageSubject.onNext(image)
                } else {
                    owner.showAlertController(with: .failToSavePhoto)
                }
            })
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(StorageReference.self)
            .bind(with: self, onNext: { owner, item in
                owner.overlayButton.isHidden = false
                
                Task {
                    let url = try await item.downloadURL()
                    owner.addSVGImage(url)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func addSVGImage(_ url: URL) {
        // svg 이미지를 추가하기 전, 이전 추가된 이미지는 삭제
        phAssetImageView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let imageView = IdentifiableImageView(frame: .zero).then {
            $0.setSVGImage(with: url)
            $0.contentMode = .scaleAspectFit
            
            let imageBounds = phAssetImageView.imageBounds
            let width = min(imageBounds.width * 0.8, imageBounds.height * 0.8)
            $0.setFrame(with: phAssetImageView.center,
                        size: CGSize(width: width, height: width))
        }
        
        phAssetImageView.addSubview(imageView)
    }
    
    func exportImage() -> UIImage? {
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
}
