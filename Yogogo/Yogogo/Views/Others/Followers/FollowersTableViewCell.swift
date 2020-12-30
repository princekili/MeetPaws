//
//  FollowersTableViewCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/29.
//

import UIKit
import Kingfisher

protocol RemoveButtonDidTapDelegate: AnyObject {
    func removeFollower()
}

enum FollowType: Int {
    case followers, following
}

class FollowersTableViewCell: UITableViewCell {

    static let identifier = "FollowersTableViewCell"
    
    weak var delegateRemoveButton: RemoveButtonDidTapDelegate?
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var removeButton: UIButton! {
        didSet {
            removeButton.layer.borderWidth = 0.5
            removeButton.layer.borderColor = UIColor.gray.cgColor
            removeButton.layer.cornerRadius = 4
            removeButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var followingButton: UIButton! {
        didSet {
            followingButton.layer.borderWidth = 0.5
            followingButton.layer.borderColor = UIColor.gray.cgColor
            followingButton.layer.cornerRadius = 4
            followingButton.layer.masksToBounds = true
        }
    }
    
    // MARK: -
    
    @IBAction func removeButtonDidTap(_ sender: UIButton) {
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
    }
    
    // MARK: -
    
    func setupForCurrentUser(with user: User, type: FollowType) {
        
        let url = URL(string: user.profileImage)
        profileImageView.kf.setImage(with: url)
        
        usernameLabel.text = user.username
        
        if user.fullName.isEmpty || user.fullName == " " {
            nameLabel.isHidden = true
        } else {
            nameLabel.text = user.fullName
        }
        
        switch type {
        case .followers:
            removeButton.isHidden = false
            followingButton.isHidden = true
            
        case .following:
            removeButton.isHidden = true
            followingButton.isHidden = false
        }
    }
    
    func setupForOtherUsers(with user: User) {
        
        let url = URL(string: user.profileImage)
        profileImageView.kf.setImage(with: url)
        
        usernameLabel.text = user.username
        
        if user.fullName.isEmpty || user.fullName == " " {
            nameLabel.isHidden = true
        } else {
            nameLabel.text = user.fullName
        }
        
        guard let currentUser = UserManager.shared.currentUser else { return }
        if user.userId == currentUser.userId {
            removeButton.isHidden = true
            followingButton.isHidden = true
        
        } else if currentUser.following.contains(user.userId) {
            removeButton.isHidden = true
            followingButton.isHidden = false
            
        } else {
            removeButton.isHidden = true
            followingButton.setTitle("Follow", for: .normal)
            followingButton.setTitleColor(.white, for: .normal)
            followingButton.backgroundColor = .systemBlue
            followingButton.layer.borderWidth = 0
            followingButton.layer.cornerRadius = 4
            followingButton.layer.masksToBounds = true
        }
    }
}
