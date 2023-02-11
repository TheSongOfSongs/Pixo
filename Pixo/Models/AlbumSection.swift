//
//  AlbumSection.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/11.
//

import RxDataSources

struct AlbumSection {
  var header: String
  var items: [Item]
}

extension AlbumSection: SectionModelType {
  typealias Item = Album

   init(original: AlbumSection, items: [Item]) {
    self = original
    self.items = items
  }
}
