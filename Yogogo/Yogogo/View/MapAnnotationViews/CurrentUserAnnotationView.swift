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
        let url = "https://firebasestorage.googleapis.com/v0/b/mchat-764dc.appspot.com/o/ProfileImages%2F57ACD8E0-ED89-4BF0-93C1-BD1EB162C253.jpg?alt=media&token=f0520034-1b44-41d5-a0bb-53e2d3a0f323"
        imageView.loadImage(url: url)
        
        imageLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
        imageLayer.masksToBounds = true
        imageLayer.borderWidth = 2
        imageLayer.borderColor = UIColor.white.cgColor
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
