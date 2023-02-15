//
//  IdentifiableImageView.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/15.
//

import UIKit
import Kingfisher

final class IdentifiableImageView: UIImageView {
    
    /// ReusableView에서 발생하는 이미지 깜빡임 이슈를 막기 위한 identifier
    var urlString: String?
    
    /// URL로부터 받아온 데이터를 svg 이미지로 가공하기 위한 processor
    lazy var processor = SVGImgProcessor(identifier: urlString ?? "")
    
    /// 캐싱된 이미지가 있으면 사용하고, 없으면 URL로부터 데이터를 받아와 svg 이미지를 할당 후 캐싱처리합니다.
    func setSVGImage(with url: URL) {
        self.urlString = url.absoluteString
        
        guard let urlString = urlString else {
            return
        }
        
        ImageCache.default.retrieveImage(forKey: urlString, options: [.processor(self.processor)]) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                // 캐시에서 가져온 이미지가 있으면 이미지 할당 후 리턴
                if let image = value.image {
                    self.image = image
                    return
                }
                
                // 캐싱된 이미지가 없으면 URL로부터 이미지를 가져와 할당하고 캐싱처리
                let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                
                // identifier로 원하는 이미지 뷰가 맞는지 확인 (cell 재사용으로 인한 깜빡임 이슈고려)
                guard self.urlString == urlString else {
                    return
                }
                
                self.kf.setImage(with: resource, options: [.processor(self.processor)])
            case .failure(let error):
                NSLog("❗️ error ==> \(error.localizedDescription)")
            }
        }
    }
}
