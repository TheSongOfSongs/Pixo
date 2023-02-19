//
//  ImageCacheManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/19.
//

import UIKit

/// URL로부터 이미지를 가져온 다음 캐싱처리하는 매니저입니다.
///
/// key 값은 URL의 절대경로이며 URL로부터 가져온 이미지를  value로 저장합니다.
class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() { }
}
