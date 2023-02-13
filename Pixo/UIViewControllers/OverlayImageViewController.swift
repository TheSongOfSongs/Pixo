//
//  OverlayImageViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/13.
//

import UIKit

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
        
        // viewModel
        let fetchSVGImageSections = PublishSubject<Void>()
        let input = OverlayImageViewModel.Input(fetchSVGImageSections: fetchSVGImageSections.asObservable())
        let output = viewModel.transform(input: input)
        
        output.svgImageSections
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        fetchSVGImageSections.onNext(())
    }
}
