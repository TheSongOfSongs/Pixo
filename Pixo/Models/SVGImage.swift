//
//  SVGImage.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import UIKit
import FirebaseStorage

/// 저장소에서 가져온 svg 이미지를 감싼 타입입니다.
struct SVGImage {
    var storageReference: StorageReference
    
    /// 이미지를 다운로드받을 수 있는 URL 값으로 캐시를 저장할 때 사용되는 key 값입니다.
    var cacheKey: NSString {
        return NSString(string: storageReference.fullPath)
    }
}
