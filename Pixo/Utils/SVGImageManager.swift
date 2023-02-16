//
//  SVGImageManager.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/15.
//

import Foundation
import FirebaseStorage


/// FirebaseStorage로부터 svg 이미지를 가져오는 기능을 담당합니다
final class SVGImageManager {
    
    typealias FetcingSVGImagesResult = (storageReferences: [StorageReference], pageToken: String?)
    
    /// 한 번 요청 시 최대로 가져올 수 있는 이미지 수
    let maxResults: Int64 = 20
    
     /// API를 통해 반환했을 때 이전 결과에서 반환된 마지막 항목의 경로와 버전을 인코딩한 값
    var pageToken: String?
    
    /**
     저장소에서 이미지를 가져옵니다.
     pageToken 값이 존재하면 후속요청으로 pageToken 뒤에 오는 항목들이 반환됩니다.
     
     pageToken: API를 통해 반환했을 때 이전 결과에서 반환된 마지막 항목의 경로와 버전을 인코딩한 값. 페이지네이션을 위해 사용됩니다.
     */
    func fetchSVGImages(with pageToken: String?) async -> Result<FetcingSVGImagesResult, Error> {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        do {
            var result: StorageListResult
            
            // pageToken이 존재하면 데이터 추가 요청, 없으면 데이터 신규 요청
            if let pageToken = pageToken {
                result = try await storageReference.list(maxResults: maxResults, pageToken: pageToken)
            } else {
                result = try await storageReference.list(maxResults: maxResults)
            }
            
            return .success((result.items, result.pageToken))
        } catch let error {
            NSLog("❗️ error ==> \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
