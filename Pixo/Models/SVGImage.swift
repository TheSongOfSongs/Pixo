//
//  SVGImage.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import UIKit

struct SVGImage {
    var name: String
    var image: UIImage? {
        return UIImage(named: name)
    }
}
