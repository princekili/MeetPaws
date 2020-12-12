//
//  CurrentUserAnnotationView.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Mapbox

class CurrentUserAnnotationView: MGLUserLocationAnnotationView {
    
    let size: CGFloat = 48
    
    let imageLayer = CALayer()
    
    // MARK: - Mock data for test
    
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }
        let imageView = UIImageView()
        let url = UserManager.shared.currentUser?.profileImage
        imageView.loadImage(url: url ?? "")
        
        imageLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
        imageLayer.masksToBounds = true
        imageLayer.borderWidth = 2
        imageLayer.borderColor = UIColor.systemBlue.cgColor
        layer.addSublayer(imageLayer)
    }
    
    // MARK: - the real one
    
//    override func update() {
//        if frame.isNull {
//            frame = CGRect(x: 0, y: 0, width: size, height: size)
//            return setNeedsLayout()
//        }
//        let imageView = UIImageView()
//        imageView.loadImage(url: CurrentUser.profileImage ?? "")
//
//        imageLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
//        imageLayer.contents = imageView.image?.cgImage
//        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
//        imageLayer.masksToBounds = true
//        imageLayer.borderWidth = 2
//        imageLayer.borderColor = UIColor.white.cgColor
//        layer.addSublayer(imageLayer)
//    }
}
