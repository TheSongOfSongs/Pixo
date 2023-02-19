//
//  ExportViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit
import Photos

import RxCocoa
import RxDataSources
import RxSwift

class ExportViewController: UIViewController {
    
    // MARK: - properties
    let viewModel = ExportViewModel()
    let imageMergingSources: ImageMergingSources
    
    /// bottomSheetView의 dataSource로 할당될 배열
    var formats: [ExportSetting] = []
    
    /// bottomSheetView의 dataSource로 할당될 배열
    var qualities: [ExportSetting] = []
    
    var phAsset: PHAsset {
        return imageMergingSources.phAsset
    }
    
    // MARK: - properties Rx
    let setSelectedFormat = PublishRelay<ExportSetting>()
    let setSelectedQuality = PublishRelay<ExportSetting>()
    
    lazy var selectedFormat = setSelectedFormat.share()
    lazy var selectedQuality = setSelectedQuality.share()
    
    // MARK: - properties UI
    let phAssetImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .beige
    }
    
    let exportSettingView: ExportSettingView = ExportSettingView(frame: .zero)
    
    let exportButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        $0.setTitle("내보내기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let bottomSheetView = ExportSettingBottmSheetView(frame: .zero)
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()

    // MARK: - life cycle
    init(imageMergingSources: ImageMergingSources, previewImage: UIImage) {
        self.imageMergingSources = imageMergingSources
        self.phAssetImageView.image = previewImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupLayout()
        setupNavigationBar()
    }
    
    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        exportButton.addGradientLayer(colors: [.pink, .magenta], direction: .horizontal)
    }
    
    // MARK: - helpers
    func bind() {
        let mergeAndExportImage = PublishSubject<ImageMergingSources>()
        let output = viewModel.transform(input: ExportViewModel.Input(phAsset: phAsset,
                                                                      mergeAndExportImage: mergeAndExportImage.asObservable(),
                                                                      format: selectedFormat.map({ $0 as? Format }),
                                                                      quality: selectedQuality.map({ $0 as? Quality })))
        
        formats = output.formats
        qualities = output.qualities
        
        exportSettingView.showFixedBottomSheet
            .bind(with: self, onNext: { owner, type in
                let settings: [ExportSetting] = {
                    switch type {
                    case .format:
                        return owner.formats
                    case .quality:
                        return owner.qualities
                    }
                }()
                
                owner.bottomSheetView.exportSettings.accept(settings)
                owner.bottomSheetView.type.accept(type)
                owner.showBottomSheetView()
            })
            .disposed(by: disposeBag)
        
        bottomSheetView.closeButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.hideBottomSheetView()
            })
            .disposed(by: disposeBag)
        
        bottomSheetView.selectedExportSetting
            .bind(with: self, onNext: { owner, result in
                let type = result.type
                let option = result.option
                
                switch type {
                case .format:
                    owner.setSelectedFormat.accept(option)
                case .quality:
                    owner.setSelectedQuality.accept(option)
                }
                
                owner.hideBottomSheetView()
            })
            .disposed(by: disposeBag)
        
        exportButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                mergeAndExportImage.onNext(owner.imageMergingSources)
            })
            .disposed(by: disposeBag)
        
        output.alert
            .drive(with: self, onNext: { owner, type in
                owner.showAlertController(with: type)
            })
            .disposed(by: disposeBag)
        
        selectedQuality
            .bind(to: exportSettingView.selectedQuality)
            .disposed(by: disposeBag)
        
        selectedFormat
            .bind(to: exportSettingView.selectedFormat)
            .disposed(by: disposeBag)
        
        // 초기값 세팅
        setSelectedFormat.accept(formats[0])
        setSelectedQuality.accept(qualities[1])
    }
    
    func setupNavigationBar() {
        title = "내보내기"
        navigationController?.isNavigationBarHidden = false
        
        let closeButton = UIBarButtonItem(title: "닫기", style: .done, target: self, action: #selector(goPhotoPickerViewController))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc func goPhotoPickerViewController() {
        guard let viewControllers = navigationController?.viewControllers,
              let photoPickerViewController = viewControllers.first(where: { $0 is PhotoPickerViewController }) else {
            return
        }
        
        navigationController?.popToViewController(photoPickerViewController, animated: true)
    }
}
