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
    let viewModel = ExportSettingViewModel()
    var formats: [ExportSettig] = []
    var qualities: [ExportSettig] = []
    var selectedSetting: [ExportSettig] = []
    var selectedFormat = PublishSubject<ExportSettig>()
    var selectedQuality = PublishSubject<ExportSettig>()
    
    
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
        let output = viewModel.transform(input: ExportSettingViewModel.Input(phAsset: phAsset))
        self.formats = output.formats
        self.qualities = output.qualities
        
        // 선택된 format이나 quality가 변경될 때마다 table view 업데이트
        Observable.combineLatest(selectedFormat, selectedQuality)
            .bind(with: self, onNext: { owner, items in
                owner.selectedSetting = [items.0, items.1]
                owner.selectedExportSettingTableView.reloadData()
                print(owner.selectedSetting)
            })
            .disposed(by: disposeBag)
        
        // 초기값 설정
        selectedFormat.onNext(formats[0])
        selectedQuality.onNext(qualities[0])
    }
}
