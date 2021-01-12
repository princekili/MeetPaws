//
//  UIView + Extension.swift
//  MeetPaws
//
//  Created by prince on 2020/12/2.
//

import UIKit

extension UIView {
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
    
    // MARK: -
    
    func enableLongPress(sender: Any, select: Selector) {

        let longPress = UILongPressGestureRecognizer(target: sender, action: select)
        
        self.addGestureRecognizer(longPress)
    }
}
