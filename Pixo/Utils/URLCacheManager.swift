//
//  URLCacheManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/16.
//

import UIKit

/// StorageReference로부터 URL을 가져와 캐싱처리하는 매니저입니다,
///
/// key 값은 StorageReference의 fullPath이며 downloadURL을 value로 저장합니다.
class URLCacheManager {
    
    static let shared = NSCache<NSString, NSString>()
    
    private init() { }
}


class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() { }
}
