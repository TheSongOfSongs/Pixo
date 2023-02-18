//
//  ExportSettingViewModel.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/18.
//

import UIKit
import Photos
import RxSwift

class ExportSettingViewModel: ViewModel {
    
    struct Input {
        let phAsset: PHAsset
    }
    
    struct Output {
        let formats: [ExportSettig]
        let qualities: [ExportSettig]
    }
    
    var disposeBag = DisposeBag()
    
    // MARK: - life cycle
    deinit {
        disposeBag = DisposeBag()
    }
    
    // MARK: - helpers
    func transform(input: Input) -> Output {
        let formats = [
            ExportSettig(title: "JPG", subtitle: "투명도 없음. 공유하기에 가장 좋습니다."),
            ExportSettig(title: "PNG", subtitle: "투명도를 갖춘 최상의 이미지 품질")
        ]
        
        let phAsset = input.phAsset
        
        let qualities = [
            ExportSettig(title: "낮은", subtitle: "\(Int(phAsset.pixelWidth/2)) x \(Int(phAsset.pixelHeight/2))"),
            ExportSettig(title: "최적", subtitle: "\(Int(phAsset.pixelWidth)) x \(Int(phAsset.pixelHeight))"),
            ExportSettig(title: "낮은", subtitle: "\(Int(phAsset.pixelWidth*2)) x \(Int(phAsset.pixelHeight*2))")
        ]
        
        return Output(formats: formats, qualities: qualities)
    }
}

