//
//  UserPostCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/14.
//

import UIKit

class UserPostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "UserPostCollectionViewCell"
    
    var user: User?

    @IBOutlet weak var postImageView: UIImageView!
    
    func setup(post: Post) {
        
        // Get post's author info from DB
        UserManager.shared.getAuthorInfo(userId: post.userId) { [weak self] (user) in
            
            let url = URL(string: post.imageFileURL)
            self?.postImageView.kf.setImage(with: url)
        }
    }
}
