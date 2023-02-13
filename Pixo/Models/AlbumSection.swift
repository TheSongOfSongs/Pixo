//
//  AlbumSection.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import RxDataSources

struct AlbumSection {
    var type: AlbumType
    var items: [Item]
    
    init(type: AlbumType, items: [Item]) {
        self.type = type
        self.items = items
    }
}

extension AlbumSection: SectionModelType {
    typealias Item = Album
    
    init(original: AlbumSection, items: [Item]) {
        self = original
        self.items = items
    }
}
