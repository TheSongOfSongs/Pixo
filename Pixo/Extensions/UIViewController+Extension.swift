//
//  UIViewController+Extension.swift
//  Pixo
//
//  Created by Jinhyang Kim on 2023/02/14.
//

import UIKit

extension UIViewController {
    func showAlertController(with type: AlertType) {
        let body = type.body
        let alert = UIAlertController(title: body.title, message: body.message, preferredStyle: .alert)
        let action = UIAlertAction(title: body.okay, style: .destructive)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
