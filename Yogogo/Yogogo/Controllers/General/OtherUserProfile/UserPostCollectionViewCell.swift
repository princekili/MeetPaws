//
//  UserPostCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/14.
//

import UIKit

class UserPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UserPostCollectionViewCell"

    @IBOutlet weak var postImageView: UIImageView!
    
    func setup(with model: Post) {
        let url = URL(string: model.imageFileURL)
        postImageView.kf.setImage(with: url)
    }
    
    func setupForTest() {
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/yogogo-ddcf9.appspot.com/o/photos%2F-MORz38gz40Eq-RV_H0m.jpg?alt=media&token=456c2a8a-6992-47ae-b752-cd31bda1a103")
        
        postImageView.kf.setImage(with: url)
    }
}
