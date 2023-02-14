//
//  OverlayImageViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit
import Photos

import RxCocoa
import RxDataSources
import RxSwift

class OverlayImageViewController: UIViewController {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<SVGImageSection>
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    let viewModel = OverlayImageViewModel()
    let sectionInsets = UIEdgeInsets(top: 32, left: 40, bottom: 39, right: 40)
    let padding: CGFloat = 16
    let itemsPerColumn: CGFloat = 1
    var phAsset: PHAsset?
    
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
            
            cell.imageView.image = item.image
            return cell
        })
    }
    
    // MARK: Properties - UI
    let topView = UIView()
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "close"), for: .normal)
    }
    
    let overlayButton = UIButton().then {
        $0.titleLabel?.font = .button
        $0.makeCornerRounded(radius: 16)
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
    
    var phAssetImageView = UIImageView().then {
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
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    // MARK: -
    func bind() {
        guard let phAsset = phAsset else {
            // TODO: 이미지 없을 때 앨범으로 돌아가도록 핸들링
            return
        }
        
        // viewModel
        let fetchSVGImageSections = PublishSubject<Void>()
        let requestPHassetImage = PublishSubject<(PHAsset, CGSize)>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable(),
                                                requestPHAssetImage: requestPHassetImage.asObserver())
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
                // TODO: 오버레이 이미지 추출
            })
            .disposed(by: disposeBag)
    }
}
