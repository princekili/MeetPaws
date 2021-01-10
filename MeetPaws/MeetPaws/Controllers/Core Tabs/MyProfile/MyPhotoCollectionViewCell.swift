//
//  PhotoCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit
import Kingfisher

class MyPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"

    @IBOutlet weak var photoImageView: UIImageView!
    
    func setup(with model: Post) {
        let url = URL(string: model.imageFileURL)
        photoImageView.kf.setImage(with: url)
    }
    
    func setupForTest() {
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/yogogo-ddcf9.appspot.com/o/photos%2F-MORz38gz40Eq-RV_H0m.jpg?alt=media&token=456c2a8a-6992-47ae-b752-cd31bda1a103")
        
        photoImageView.kf.setImage(with: url)
    }
}
