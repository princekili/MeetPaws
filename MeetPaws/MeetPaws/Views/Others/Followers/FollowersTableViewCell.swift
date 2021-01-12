//
//  FollowersTableViewCell.swift
//  MeetPaws
//
//  Created by prince on 2020/12/29.
//

import UIKit
import Kingfisher

protocol RemoveButtonDidTapDelegate: AnyObject {
    func presentAlert(for user: User, cell: UITableViewCell)
}

enum FollowType: Int {
    case followers, following
}

class FollowersTableViewCell: UITableViewCell {

    static let identifier = "FollowersTableViewCell"
    
    weak var delegateRemoveButton: RemoveButtonDidTapDelegate?
    
    var user: User?
    
    var index: Int?
    
    // MARK: - @IBOutlet
    
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
    
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.layer.cornerRadius = 4
            followButton.layer.masksToBounds = true
        }
    }
    
    // MARK: -
    
    @IBAction func removeButtonDidTap(_ sender: UIButton) {
        guard let user = self.user else { return }
        self.delegateRemoveButton?.presentAlert(for: user, cell: self)
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
        guard let user = self.user else { return }
        FollowManager.shared.unfollow(the: user)
        followButton.isHidden = false
        followingButton.isHidden = true
    }
    
    @IBAction func followButtonDidTap(_ sender: UIButton) {
        guard let user = self.user else { return }
        FollowManager.shared.follow(the: user)
        followButton.isHidden = true
        followingButton.isHidden = false
    }
    
    // MARK: -
    
    func setupForCurrentUser(with user: User, type: FollowType, at index: Int) {
        self.user = user
        self.index = index
        setupProfileImage(with: user)
        setupUsernameLabel(with: user)
        setupNameLabel(with: user)
        setupFollowType(with: type)
    }
    
    func setupForOtherUsers(with user: User) {
        self.user = user
        setupProfileImage(with: user)
        setupUsernameLabel(with: user)
        setupNameLabel(with: user)
        setupUserStatus(with: user)
    }
    
    // MARK: -
    
    private func setupProfileImage(with user: User) {
        let url = URL(string: user.profileImage)
        profileImageView.kf.setImage(with: url)
    }
    
    private func setupUsernameLabel(with user: User) {
        usernameLabel.text = user.username
    }
    
    private func setupNameLabel(with user: User) {
        if user.fullName.isEmpty || user.fullName == " " {
            nameLabel.isHidden = true
        } else {
            nameLabel.text = user.fullName
        }
    }
    
    // For current user
    private func setupFollowType(with type: FollowType) {
        switch type {
        case .followers:
            removeButton.isHidden = false
            followingButton.isHidden = true
            followButton.isHidden = true
            
        case .following:
            removeButton.isHidden = true
            followingButton.isHidden = false
            followButton.isHidden = true
        }
    }
    
    // For other user
    private func setupUserStatus(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        if user.userId == currentUser.userId {
            removeButton.isHidden = true
            followingButton.isHidden = true
            followButton.isHidden = true

        } else if currentUser.following.contains(user.userId) {
            removeButton.isHidden = true
            followingButton.isHidden = false
            followButton.isHidden = true
            
        } else {
            removeButton.isHidden = true
            followingButton.isHidden = true
            followButton.isHidden = false
        }
    }
}
