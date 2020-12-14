//
//  CurrentUserAnnotationView.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Mapbox
import Kingfisher

class CurrentUserAnnotationView: MGLUserLocationAnnotationView {
    
    let size: CGFloat = 48
    
    let imageLayer = CALayer()
    
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        
        let imageView = UIImageView()
        let url = URL(string: UserManager.shared.currentUser?.profileImage ?? "")
        imageView.kf.setImage(with: url)
        
        imageLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
        imageLayer.masksToBounds = true
        imageLayer.borderWidth = 2
//        imageLayer.borderColor = UIColor().hexStringToUIColor(hex: "aee6e6").cgColor // light blue
//        imageLayer.borderColor = UIColor().hexStringToUIColor(hex: "ffa45b").cgColor // orange
        imageLayer.borderColor = UIColor.systemBlue.cgColor
        layer.addSublayer(imageLayer)
    }
}
