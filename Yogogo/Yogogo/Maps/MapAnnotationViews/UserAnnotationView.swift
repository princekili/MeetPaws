//
//  UserAnnotationView.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Mapbox

class UserAnnotationView: MGLAnnotationView {
    
    let size: CGFloat = 48
    
    let imageLayer = CALayer()
    
    init(annotation: MGLAnnotation?, reuseIdentifier: String?, user: User) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView()
        imageView.loadImage(url: user.profileImage ?? "")
        
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
        imageLayer.masksToBounds = true
        imageLayer.borderWidth = 2
        imageLayer.borderColor = UIColor.white.cgColor
        layer.addSublayer(imageLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
