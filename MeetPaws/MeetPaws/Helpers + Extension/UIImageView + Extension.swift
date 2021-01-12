//
//  UIImageView + Extension.swift
//  MeetPaws
//
//  Created by prince on 2020/11/29.
//

// MARK: Load images from Firebase Storage and caches them.

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return activityIndicator
    }
    
    // MARK: -
    
    func enableTapAction(sender: Any, selector: Selector) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: sender, action: selector)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGestureRecognizer)
    }
}
