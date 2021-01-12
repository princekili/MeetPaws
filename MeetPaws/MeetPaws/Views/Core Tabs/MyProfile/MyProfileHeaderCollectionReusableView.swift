//
//  ProfileInfoHeaderCollectionReusableView.swift
//  MeetPaws
//
//  Created by prince on 2020/12/2.
//

import UIKit

protocol MyProfileHeaderCollectionReusableViewDelegate: AnyObject {

    func postsButtonDidTap(_ header: UICollectionReusableView)
    
    func followersButtonDidTap()
    
    func followingButtonDidTap()
}

final class MyProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "MyProfileHeaderCollectionReusableView"
    
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
    
    @IBOutlet weak var editProfileButton: UIButton! {
        didSet {
            editProfileButton.layer.borderWidth = 0.5
            editProfileButton.layer.borderColor = UIColor.lightGray.cgColor
            editProfileButton.layer.cornerRadius = 4
            editProfileButton.layer.masksToBounds = true
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
    
    // MARK: -
    
    func setup() {
        guard let currentUser = UserManager.shared.currentUser else { return }
        setupProfileImage(with: currentUser)
        setupNameLabel(with: currentUser)
        setupBioLabel(with: currentUser)
        setupCounts(with: currentUser)
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
}
