//
//  UINavigationController + Extension.swift
//  MeetPaws
//
//  Created by prince on 2020/12/8.
//

import UIKit

extension UINavigationController {
    
    var rootViewController: UIViewController? {
        return self.viewControllers.first
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .label
        
        // Make the navigation bar transparent
        navigationBar.isTranslucent = false
    }
}
