//
//  ProfileInfoHeaderCollectionReusableView.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class MyProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    let userManager = UserManager.shared
        
    static let identifier = "MyProfileHeaderCollectionReusableView"
    
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
        guard let profileImage = userManager.currentUser?.profileImage else { return }
        let url = URL(string: profileImage)
        profileImageView.kf.setImage(with: url)
        
        nameLabel.text = userManager.currentUser?.fullName
        bioLabel.text = userManager.currentUser?.bio
        
        let postsCount = String((userManager.currentUser?.posts.count ?? 1) - 1)
            postsCountButton.setTitle(postsCount, for: .normal)
        
        let followersCount = String((userManager.currentUser?.followers.count ?? 1) - 1)
        followersCountButton.setTitle(followersCount, for: .normal)
        
        let followingCount = String((userManager.currentUser?.following.count ?? 1) - 1)
        followingCountButton.setTitle(followingCount, for: .normal)
    }
}
