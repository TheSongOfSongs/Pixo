//
//  PhotoPickerViewController.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/10.
//

import UIKit
import Photos

import RxCocoa
import RxSwift

class PhotoPickerViewController: UIViewController {
    
    // MARK: Properties
    let disposeBag = DisposeBag()
    let viewModel = PhotoPickerViewModel()
    var fetchAlbumsSubject = PublishSubject<Void>()
    var allPhotos: Album?
    var smartAlbums: [Album] = []
    var userCollections: [Album] = []
    
    // cell previewImage
    let imageManager = PHCachingImageManager()
    let previewSize = CGSize(width: 64, height: 64)
    
    
    // MARK: Properties - UI
    let titleView = PhotoPickerTitleView(frame: .zero)
    
    let tableView = UITableView().then {
        $0.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.identifier)
        $0.rowHeight = 85
        $0.separatorStyle = .none
    }
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bind()
        setupTableView()
    }

    override func loadView() {
        let view = UIView().then {
            $0.backgroundColor = .systemBackground
        }
        
        self.view = view
    }
    
    
    // MARK: -
    func bind() {
        titleView.photoPickerObservable
            .bind(with: self, onNext: { owner, photoPicker in
                // TODO: 사진/앨범 리스트 보여주기
                print("💖 \(photoPicker)")
            })
            .disposed(by: disposeBag)
        
        let input = PhotoPickerViewModel.Input(fetchAlbums: fetchAlbumsSubject.asObservable())
        let output = viewModel.transform(input: input)
        
        Observable.combineLatest(output.allPhotos, output.userCollections, output.smartAlbums)
            .subscribe(with: self, onNext: { owner, results in
                owner.allPhotos = results.0
                owner.userCollections = results.1
                owner.smartAlbums = results.2
                owner.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        fetchAlbumsSubject.onNext(())
    }
}
