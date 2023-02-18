//
//  ExportSettingBottmSheetView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit
import RxSwift
import RxCocoa

class ExportSettingBottmSheetView: UIView {
    
    // MARK: - properties
    
    // MARK: - properties Rx
    var disposeBag = DisposeBag()
    let type = BehaviorRelay<ExportSettingView.ExportSettingType>(value: .format)
    let exportSettings = BehaviorRelay<[ExportSettig]>(value: [])
    let selectedExportSetting = PublishRelay<(ExportSettig, ExportSettingView.ExportSettingType)>()
    
    // MARK: - properties UI
    lazy var titleLabel = UILabel().then {
        $0.font = .title
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "close"), for: .normal)
    }
    
    let exportSettingsTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.register(ExportSettingDetailTableViewCell.self, forCellReuseIdentifier: ExportSettingDetailTableViewCell.identifier)
        $0.rowHeight = 66
        $0.backgroundColor = .systemBackground
        $0.isScrollEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUpperCornerRounded(radius: 15)
        
        exportSettingsTableView.dataSource = self
        exportSettingsTableView.delegate = self
        backgroundColor = .systemBackground
        setupLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func bind() {
        type.bind(with: self, onNext: { owner, type in
            owner.titleLabel.text = type.name
        })
        .disposed(by: disposeBag)
        
        exportSettings
            .filter({ !$0.isEmpty })
            .bind(with: self, onNext: { owner, exportSettings in
            owner.exportSettingsTableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
}
