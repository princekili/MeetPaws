//
//  UINavigationController + Extension.swift
//  Yogogo
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
        
//        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.tintColor = UIColor.label
        
//        guard let font = UIFont(name: "Chalkboard-SE-Regular", size: 26) else { return }
//        self.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.font: font,
//            NSAttributedString.Key.foregroundColor: UIColor.label
//        ]
        
//        self.navigationBar.titleTextAttributes = [
//            NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 20)!,
//            NSAttributedString.Key.foregroundColor: UIColor.white
//        ]
    }
}
