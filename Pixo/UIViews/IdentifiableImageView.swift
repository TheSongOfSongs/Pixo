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
    func setSVGImage(with svgImage: SVGImage) async {
        guard let url = await url(item: svgImage) else {
            return
        }
        
        urlString = url.absoluteString
        
        guard let urlString = urlString else {
            return
        }
        
        // 캐싱된 이미지가 없으면 URL로부터 이미지를 가져와 할당하고 캐싱처리
        if let image = ImageCacheManager.shared.object(forKey: NSString(string: urlString)) {
            self.image = image
            return
        }
        
        // identifier로 원하는 이미지 뷰가 맞는지 확인 (cell 재사용으로 인한 깜빡임 이슈고려)
        guard self.urlString == urlString else {
            return
        }
        
        kf.setImage(with: url, options: [.processor(processor)]) { result in
            switch result {
            case .success(let result):
                ImageCacheManager.shared.setObject(result.image, forKey: NSString(string: urlString))
            case .failure(let error):
                NSLog("❗️ error ==> \(error.localizedDescription)")
            }
        }
    }
    
    /// SVGImage로부터 다운로드할 이미지의 URL을 리턴합니다
    private func url(item: SVGImage) async -> URL? {
        do {
            let cacheKey = item.cacheKey
            
            // 캐싱된 URL이 있으면 return
            if let urlString = URLCacheManager.shared.object(forKey: cacheKey),
               let url = URL(string: String(urlString)) {
                return url
            }
            
            // 없으면 URL 가져와서 return
            let url = try await item.storageReference.downloadURL()
            URLCacheManager.shared.setObject(NSString(string: url.absoluteString),
                                             forKey: item.cacheKey)
            return url
        } catch let error {
            NSLog("❗️ error ==> \(error.localizedDescription)")
            return nil
        }
    }
}
