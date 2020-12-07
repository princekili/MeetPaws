//
//  PhotoCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"

    @IBOutlet weak var photoImageView: UIImageView!
    
    func setup(with model: Post) {
        let url = URL(string: model.imageFileURL)
        photoImageView.kf.setImage(with: url)
    }
    
    func setupForTest() {
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/mchat-764dc.appspot.com/o/ProfileImages%2F57ACD8E0-ED89-4BF0-93C1-BD1EB162C253.jpg?alt=media&token=f0520034-1b44-41d5-a0bb-53e2d3a0f323")
        
        photoImageView.kf.setImage(with: url)
    }
}
