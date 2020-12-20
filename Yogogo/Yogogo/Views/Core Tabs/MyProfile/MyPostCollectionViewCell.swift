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
    
//    func setupForTest() {
//        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/yogogo-ddcf9.appspot.com/o/profilePhotos%2FOah68lc0QpdSXKbGIYM1MzzsF8w2.jpg?alt=media&token=2931e8b2-71d3-46d7-95e8-64b5472752e3")
//
//        postImageView.kf.setImage(with: url)
//    }
}
