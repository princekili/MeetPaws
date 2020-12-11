//
//  ProfileInfoHeaderCollectionReusableView.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class MyProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    let userManager = UserManager.shared
        
    static let identifier = "MyProfileInfoHeaderCollectionReusableView"
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
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
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var postsCountButton: UIButton!
    
    @IBOutlet weak var followersCountButton: UIButton!
    
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBAction func postsButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followersButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
    }
    
    func setup() {
        let url = URL(string: userManager.profileImage)
        profileImageView.kf.setImage(with: url)
        
        nameLabel.text = userManager.currentUser?.fullName
        bioLabel.text = userManager.currentUser?.bio
        
        let postsCount = String(userManager.currentUser?.posts.count ?? 0)
            postsCountButton.setTitle(postsCount, for: .normal)
        
        let followersCount = String(userManager.currentUser?.followers.count ?? 0)
        followersCountButton.setTitle(followersCount, for: .normal)
        
        let followingCount = String(userManager.currentUser?.following.count ?? 0)
        followingCountButton.setTitle(followingCount, for: .normal)
    }
}
