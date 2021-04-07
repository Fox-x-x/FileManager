//
//  AutoLayout.swift
//  FileManager
//
//  Created by Pavel Yurkov on 05.04.2021.
//

import UIKit

extension UIView {
    func addSubviewWithAutolayout(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
}
