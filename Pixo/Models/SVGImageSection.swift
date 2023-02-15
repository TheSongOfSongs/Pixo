//
//  SVGImageSection.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import Foundation
import RxDataSources

struct SVGImageSection {
    var items: [Item]
}

extension SVGImageSection: SectionModelType {
    typealias Item = SVGImage
    
    init(original: SVGImageSection, items: [Item]) {
        self = original
        self.items = items
    }
}
