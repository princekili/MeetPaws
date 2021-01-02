//
//  UserPostCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/14.
//

import UIKit
import Kingfisher

class UserPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UserPostCollectionViewCell"
    
    var user: User?

    @IBOutlet weak var postImageView: UIImageView!
    
    func setup(post: Post) {
        if let ignoreList = UserManager.shared.currentUser?.ignoreList {
            guard !ignoreList.contains(post.postId) else { return }
        }
        
        let url = URL(string: post.imageFileURL)
        postImageView.kf.setImage(with: url)
    }
}
