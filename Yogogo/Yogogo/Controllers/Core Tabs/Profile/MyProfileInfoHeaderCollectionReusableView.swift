//
//  ProfileInfoHeaderCollectionReusableView.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class MyProfileInfoHeaderCollectionReusableView: UICollectionReusableView {
    
    let UserManager = UserManager.shared
        
    static let identifier = "MyProfileInfoHeaderCollectionReusableView"
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            
            let url = URL(string: UserManager.profileImage)
            profileImageView.kf.setImage(with: url)
        }
    }
    
    @IBOutlet weak var editProfileButton: UIButton! {
        didSet {
            editProfileButton.layer.borderWidth = 0.5
            editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
            editProfileButton.layer.cornerRadius = 4
            editProfileButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var postsCountButton: UIButton! {
        didSet {
            let count = String(UserManager.currentUser?.posts.count ?? 0)
                postsCountButton.setTitle(count, for: .normal)
        }
    }
    
    @IBOutlet weak var followersCountButton: UIButton! {
        didSet {
            let count = String(UserManager.currentUser?.followers.count ?? 0)
            followersCountButton.setTitle(count, for: .normal)
        }
    }
    
    @IBOutlet weak var followingCountButton: UIButton! {
        didSet {
            let count = String(UserManager.currentUser?.following.count ?? 0)
            followingCountButton.setTitle(count, for: .normal)
        }
    }
    
    @IBAction func postsButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followerButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
    }
    
}
