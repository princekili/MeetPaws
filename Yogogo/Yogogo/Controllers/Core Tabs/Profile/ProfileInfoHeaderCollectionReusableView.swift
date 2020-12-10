//
//  ProfileInfoHeaderCollectionReusableView.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class ProfileInfoHeaderCollectionReusableView: UICollectionReusableView {
    
    let authManager = AuthManager.shared
        
    static let identifier = "ProfileInfoHeaderCollectionReusableView"
    
    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 100 / 2
            profileImageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            
            let url = URL(string: authManager.profileImage)
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
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var postsCountButton: UIButton!
    
    @IBOutlet weak var followersCountButton: UIButton!
    
    @IBOutlet weak var followingCountButton: UIButton!
    
    @IBAction func postsButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followerButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func editProfileButtonDidTap(_ sender: UIButton) {
    }
}
