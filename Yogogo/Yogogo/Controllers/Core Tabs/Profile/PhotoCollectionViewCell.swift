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
        let url = URL(string: model.thumbnailImage)
        photoImageView.kf.setImage(with: url)
    }
    
    func setupForTest() {
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/mchat-764dc.appspot.com/o/ProfileImages%2F4C68F0A3-C6B7-43DB-96D2-391EB16D4953.jpg?alt=media&token=96ad3668-96d2-4739-90cd-4dd1e74060f2")
        photoImageView.kf.setImage(with: url)
    }
}
