//
//  UserProfileHeaderCollectionReusableView.swift
//  MeetPaws
//
//  Created by prince on 2020/12/14.
//

import UIKit
import Kingfisher

protocol OpenUserMessagesHandlerDelegate: AnyObject {
    
    func openUserMessagesHandler()
}

class UserProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "UserProfileHeaderCollectionReusableView"
        
    let userManager = UserManager.shared
    
    var user: User?
    
    weak var delegateOpenUserMessages: OpenUserMessagesHandlerDelegate?
    
    weak var delegateForButtons: MyProfileHeaderCollectionReusableViewDelegate?
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.layer.cornerRadius = 4
            followButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var messageButton: UIButton! {
        didSet {
            messageButton.layer.borderWidth = 0.5
            messageButton.layer.borderColor = UIColor.lightGray.cgColor
            messageButton.layer.cornerRadius = 4
            messageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var postsCountButton: UIButton!
    
    @IBOutlet weak var followersButton: UIButton!
    
    @IBOutlet weak var followersCountButton: UIButton!
    
    @IBOutlet weak var followingCountButton: UIButton!
    
    // MARK: - @IBAction
    
    @IBAction func postsCountButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.postsButtonDidTap(self)
    }
    
    @IBAction func postsButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.postsButtonDidTap(self)
    }
    
    @IBAction func followersCountButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.followersButtonDidTap()
    }
    
    @IBAction func followersButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.followersButtonDidTap()
    }
    
    @IBAction func followingCountButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.followingButtonDidTap()
    }
    
    @IBAction func followingButtonDidTap(_ sender: UIButton) {
        delegateForButtons?.followingButtonDidTap()
    }
    
    @IBAction func followButtonDidTap(_ sender: UIButton) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        guard let user = self.user else { return }
        
        if currentUser.following.contains(user.userId) {
            FollowManager.shared.unfollow(the: user)
            follow()
        } else {
            FollowManager.shared.follow(the: user)
            following()
        }
    }
    
    @IBAction func messageButtonDidTap(_ sender: UIButton) {
        delegateOpenUserMessages?.openUserMessagesHandler()
    }
    
    // MARK: -
    
    func setup(user: User) {
        self.user = user
        setupFollowButton(with: user)
        setupProfileImage(with: user)
        setupNameLabel(with: user)
        setupBioLabel(with: user)
        setupCounts(with: user)
        observeUser()
    }
    
    // MARK: -
    
    private func setupProfileImage(with user: User) {
        let url = URL(string: user.profileImage)
        profileImageView.kf.setImage(with: url)
    }
    
    private func setupNameLabel(with user: User) {
        if user.fullName.isEmpty || user.fullName == " " {
            nameLabel.isHidden = true
        } else {
            nameLabel.text = user.fullName
        }
    }
    
    private func setupBioLabel(with user: User) {
        if user.bio.isEmpty || user.bio == " " {
            bioLabel.isHidden = true
        } else {
            bioLabel.text = user.bio
        }
    }
    
    private func setupCounts(with user: User) {
        let postsCount = user.posts.filter { $0 != "" }.count
        postsCountButton.setTitle("\(postsCount)", for: .normal)

        let followersCount = user.followers.filter { $0 != "" }.count
        followersCountButton.setTitle("\(followersCount)", for: .normal)
        if followersCount > 1 {
            followersButton.setTitle("Followers", for: .normal)
        } else {
            followersButton.setTitle("Follower", for: .normal)
        }

        let followingCount = user.following.filter { $0 != "" }.count
        followingCountButton.setTitle("\(followingCount)", for: .normal)
    }
    
    // MARK: - follow/following button
    
    private func following() {
        followButton.setTitle("Following", for: .normal)
        followButton.setTitleColor(.label, for: .normal)
        followButton.backgroundColor = .clear
        followButton.layer.borderWidth = 0.5
        followButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func follow() {
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = .systemBlue
        followButton.layer.borderWidth = 0
    }
    
    private func setupFollowButton(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        if currentUser.following.contains(user.userId) {
            following()
        } else {
            follow()
        }
    }
    
    // MARK: - Observe the user
    
    private func observeUser() {
        guard let user = self.user else { return }
        FollowManager.shared.observeUser(of: user.userId) { [weak self] (user) in
            self?.user = user
            self?.setupFollowButton(with: user)
        }
    }
}
