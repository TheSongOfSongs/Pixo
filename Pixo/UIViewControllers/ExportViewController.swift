//
//  ExportViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import RxCocoa
import RxDataSources
import RxSwift

class ExportViewController: UIViewController {
    
    // MARK: - properties
    
    
    // MARK: - properties UI
    
    
    
    // MARK: - properties Rx

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
