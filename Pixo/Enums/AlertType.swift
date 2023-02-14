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
        }
    }
}
