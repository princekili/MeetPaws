//
//  UIViewController + Extension.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit

extension UIViewController {
    
    // MARK: -
    
    func hideKeyboardWhenDidTapAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: -
    
    func setLeftAlignedNavigationItemTitle(text: String,
                                           color: UIColor,
                                           margin left: CGFloat) {
        let titleLabel = UILabel()
        titleLabel.textColor = color
        titleLabel.text = text
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleLabel
        
        guard let containerView = self.navigationItem.titleView?.superview else { return }
        
        // NOTE: This always seems to be 0. Huh??
        let leftBarItemWidth = self.navigationItem.leftBarButtonItems?.reduce(0, { $0 + $1.width })
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,
                                             constant: (leftBarItemWidth ?? 0) + left),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
        ])
    }
}
