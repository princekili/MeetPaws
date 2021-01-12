//
//  UserAnnotationView.swift
//  MeetPaws
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Mapbox
import Kingfisher

class UserAnnotationView: MGLAnnotationView {
    
    let size: CGFloat = 48
    
    let imageLayer = CALayer()
    
    let dogIcons = [
        "dog_icon_bm",
        "dog_icon_bj",
        "dog_icon_kg",
        "dog_icon_bg",
        "dog_icon_cc"
    ]
    
    init(annotation: MGLAnnotation?, reuseIdentifier: String?, user: User) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let imageView = UIImageView()
        let url = URL(string: user.profileImage)
        
        let randomInt = Int.random(in: 0 ..< dogIcons.count)
        let placeholder = UIImage(named: dogIcons[randomInt])
        
        imageView.kf.setImage(with: url, placeholder: placeholder)
        
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageLayer.contents = imageView.image?.cgImage
        imageLayer.cornerRadius = imageLayer.frame.size.width / 2
        imageLayer.masksToBounds = true
        imageLayer.borderWidth = 2
//        imageLayer.borderColor = UIColor.darkGray.cgColor
        imageLayer.borderColor = UIColor().hexStringToUIColor(hex: "ffda77").cgColor // light yellow
        layer.addSublayer(imageLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
