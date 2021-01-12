//
//  UIStoryboard + Extension.swift
//  MeetPaws
//
//  Created by prince on 2020/12/23.
//

import UIKit

extension UIStoryboard {
    
    static func initiateVC<T: UIViewController>(name: StoryboardName, id: StoryboardId) -> T {
        
        guard let viewController = UIStoryboard(name: name.rawValue, bundle: nil).instantiateViewController(identifier: id.rawValue) as? T else {
            fatalError("Fatal Error")
        }
        
        return viewController
    }
}
