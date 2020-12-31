//
//  PhotoCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit
import Kingfisher

class MyPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "MyPostCollectionViewCell"
    
    @IBOutlet weak var postImageView: UIImageView!
    
    func setup(with model: Post) {
        let url = URL(string: model.imageFileURL)
        postImageView.kf.setImage(with: url)
    }
}
