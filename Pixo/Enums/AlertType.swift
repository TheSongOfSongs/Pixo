//
//  AlertType.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import Foundation

enum AlertType {
    case successToSavePhoto
    case failToSavePhoto
    case failToLoadImage
    case failToLoadPhoto
    case unknown
    
    var body: (title: String, message: String?, okay: String, cancel: String?) {
        switch self {
        case .successToSavePhoto:
            return (title: "저장 완료",
                    message: "앨범에서 사진을 확인하세요!",
                    okay: "확인",
                    cancel: nil)
        case .failToSavePhoto:
            return (title: "에러 발생",
                    message: "사진을 저장할 수 없습니다 😢",
                    okay: "확인",
                    cancel: nil)
        case .failToLoadImage, .failToLoadPhoto:
            return (title: "에러 발생",
                    message: "이미지를 사용할 수 없습니다 😢",
                    okay: "확인",
                    cancel: nil)
        case .unknown:
            return (title: "에러 발생",
                    message: "알 수 없는 에러가 발생했습니다",
                    okay: "확인",
                    cancel: nil)
        }
    }
}
