//
//  CommentsTableViewCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/25.
//

import UIKit
import Kingfisher

class CommentsTableViewCell: UITableViewCell {
    
    static let identifier = "CommentsTableViewCell"
    
//    private var currentComment: Comment?
    
//    private var currentUser: User?
    
    let userManager = UserManager.shared
    
    // MARK: - @IBOutlet for cell

    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.layer.masksToBounds = true
            profileImage.translatesAutoresizingMaskIntoConstraints = false
            profileImage.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var lineView: UIView!
    
    // MARK: - For setupPost
    
    func setupPost(with post: Post) {
        selectionStyle = .none
        likeCountLabel.isHidden = true
        likeButton.isHidden = true
        setupPostAuthorInfo(with: post)
        setupCaptionLabel(with: post)
        setupTimestampLabel(with: post)
    }
    
    private func setupPostAuthorInfo(with post: Post) {
        userManager.getAuthorInfo(userId: post.userId) { [weak self] (user) in
//            self?.currentUser = user
            self?.usernameButton.setTitle(user.username, for: .normal)
            let url = URL(string: user.profileImage)
            self?.profileImage.kf.setImage(with: url)
        }
    }
    
    private func setupCaptionLabel(with post: Post) {
        contentLabel.text = post.caption
    }
    
    private func setupTimestampLabel(with post: Post) {
        let stringTimestamp = String(post.timestamp / 1000)
        let date = DateClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
    }
    
    // MARK: - For setupComment
    
    func setupComment(with comment: Comment) {
        selectionStyle = .none
//        currentComment = comment
        lineView.isHidden = true
        setupCommentAuthorInfo(with: comment)
        setupContentLabel(with: comment)
        setupTimestampLabel(with: comment)
        setupLikeCountLabel(with: comment)
        setupLikeButton(with: comment)
    }
    
    private func setupCommentAuthorInfo(with comment: Comment) {
        userManager.getAuthorInfo(userId: comment.userId) { [weak self] (user) in
//            self?.currentUser = user
            self?.usernameButton.setTitle(user.username, for: .normal)
            let url = URL(string: user.profileImage)
            self?.profileImage.kf.setImage(with: url)
        }
    }
    
    private func setupContentLabel(with comment: Comment) {
        contentLabel.text = comment.content
    }
    
    private func setupTimestampLabel(with comment: Comment) {
        let stringTimestamp = String(comment.timestamp / 1000)
        let date = DateClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
    }
    
    private func setupLikeCountLabel(with comment: Comment) {
        let count = comment.userDidLike.filter { $0 != "" }.count
        switch count {
        case 0:
            likeCountLabel.isHidden = true
        case 1:
            likeCountLabel.isHidden = false
            likeCountLabel.text = "\(count) like"
        default:
            likeCountLabel.isHidden = false
            likeCountLabel.text = "\(count) likes"
        }
    }
    
    private func setupLikeButton(with comment: Comment) {
        guard let userId = userManager.currentUser?.userId else { return }
        likeButton.isSelected = comment.userDidLike.contains(userId)
        configureLikeButton()
    }
    
    private func configureLikeButton() {
        let size: CGFloat = 10
        
        if likeButton.isSelected {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            likeButton.setImage(image, for: .selected)
            likeButton.tintColor = .systemRed
            
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .lightGray
        }
    }
}
