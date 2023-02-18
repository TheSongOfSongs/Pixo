//
//  ExportSettingView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit
import Photos

import SnapKit
import RxCocoa
import RxSwift
import Then

class ExportSettingView: UIView {
    
    /// TableView의 InexPath row를 구분하기 위한 타입
    enum ExportSettingType: Int, CaseIterable {
        case format = 0
        case quality
        
        var name: String {
            switch self {
            case .format:
                return "포맷"
            case .quality:
                return "이미지 품질"
            }
        }
    }

    // MARK: - properties
    var disposeBag = DisposeBag()
    let phAsset: PHAsset
    var formats: [ExportSettig] = []
    var qualities: [ExportSettig] = []
    var selectedSetting: [ExportSettig] = []
    
    // MARK: - properties Rx
    let showFixedBottomSheet = PublishRelay<ExportSettingType>()
    let selectedFormat = PublishSubject<ExportSettig>()
    let selectedQuality = PublishSubject<ExportSettig>()
    
    
    // MARK: - properties UI
    let titleLabel = UILabel().then {
        $0.text = "내보내기 설정"
        $0.font = UIFont.systemFont(ofSize: 13)
    }
    
    let selectedExportSettingTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(ExportSettingTableViewCell.self, forCellReuseIdentifier: ExportSettingTableViewCell.identifier)
        $0.rowHeight = 60
        $0.backgroundColor = .systemBackground
        $0.isScrollEnabled = false
    }
    
    // MARK: - life cycle
    init(frame: CGRect, phAsset: PHAsset) {
        self.phAsset = phAsset
        super.init(frame: frame)
        
        selectedExportSettingTableView.dataSource = self
        selectedExportSettingTableView.delegate = self
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    func bind() {
        // 선택된 format이나 quality가 변경될 때마다 table view 업데이트
        Observable.combineLatest(selectedFormat, selectedQuality)
            .bind(with: self, onNext: { owner, items in
                owner.selectedSetting = [items.0, items.1]
                owner.selectedExportSettingTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}
