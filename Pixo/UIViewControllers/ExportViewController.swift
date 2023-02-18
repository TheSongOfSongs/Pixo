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
    var imageMergingSources: ImageMergingSources
    var formats: [ExportSetting] = []
    var qualities: [ExportSetting] = []
    var previewImage: UIImage?
    
    var phAsset: PHAsset {
        return imageMergingSources.phAsset
    }
    
    // MARK: - properties UI
    let phAssetImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .beige
    }
    
    let exportSettingView: ExportSettingView
    
    let exportButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        $0.setTitle("내보내기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let bottomSheetView = ExportSettingBottmSheetView(frame: .zero)
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()

    // MARK: - life cycle
    init(imageMergingSources: ImageMergingSources) {
        self.imageMergingSources = imageMergingSources
        self.exportSettingView = ExportSettingView(frame: .zero,
                                                   phAsset: imageMergingSources.phAsset)
        
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
        self.phAssetImageView.image = previewImage
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
                                                                      mergeAndExportImage: mergeAndExportImage.asObservable()))
        
        exportSettingView.showFixedBottomSheet
            .bind(with: self, onNext: { owner, type in
                owner.bottomSheetView.type.accept(type)
                
                let settings: [ExportSetting] = {
                    switch type {
                    case .format:
                        return owner.formats
                    case .quality:
                        return owner.qualities
                    }
                }()
                
                owner.bottomSheetView.exportSettings.accept(settings)
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
                let setting = result.0
                let type = result.1
                
                switch type {
                case .format:
                    owner.exportSettingView.selectedFormat.onNext(setting)
                case .quality:
                    owner.exportSettingView.selectedQuality.onNext(setting)
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
        
        
        self.formats = output.formats
        self.qualities = output.qualities
        
        // 초기값 세팅
        exportSettingView.selectedFormat
            .onNext(formats[0])
        
        exportSettingView.selectedQuality
            .onNext(qualities[0])
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
