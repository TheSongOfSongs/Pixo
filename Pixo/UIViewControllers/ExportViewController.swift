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
    let image: UIImage
    let phAsset: PHAsset
    let overlayImageViews: [UIImageView]
    
    
    // MARK: - properties UI
    let phAssetImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let exportSettingView: ExportSettingView
    
    // MARK: - properties Rx

    // MARK: - life cycle
    init(image: UIImage, phAsset: PHAsset, overlayImageViews: [UIImageView]) {
        self.image = image
        self.phAsset = phAsset
        self.overlayImageViews = overlayImageViews
        self.exportSettingView = ExportSettingView(frame: .zero, phAsset: phAsset)
        
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
    
    
    // MARK: - helpers
    func bind() {
        phAssetImageView.image = image
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
