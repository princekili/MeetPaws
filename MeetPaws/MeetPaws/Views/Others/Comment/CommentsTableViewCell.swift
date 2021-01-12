//
//  CommentsTableViewCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/25.
//

import UIKit
import Kingfisher

protocol CommentsTableViewCellDelegate: AnyObject {
    func presentAlert(with comment: Comment, at index: Int)
    func presentUser(user: User, at index: Int)
}

class CommentsTableViewCell: UITableViewCell {
    
    static let identifier = "CommentsTableViewCell"
    
    private var currentUser: User?
    
    var currentComment: Comment?
    
    var index: Int?
    
    let userManager = UserManager.shared
    
    // MARK: - delegate
    
    weak var delegatePresent: CommentsTableViewCellDelegate?
    
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
    
    @IBOutlet weak var lineView: UIView!
    
    // MARK: - @IBAction
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        // Change local view
        sender.isSelected.toggle()
        configureLikeButton()
        
        // HUD
        if likeButton.isSelected {
            WrapperProgressHUD.showHeart()
        }
        
        // Data
        guard let currentComment = currentComment else { return }
        CommentManager.shared.updateUserDidLike(comment: currentComment)
    }
    
    @IBAction func usernameButtonDidTap(_ sender: UIButton) {
        guard let user = currentUser else { return }
        self.delegatePresent?.presentUser(user: user, at: sender.tag)
    }
    
    // MARK: - For setupPost
    
    func setupPost(with post: Post) {
        selectionStyle = .none
        likeButton.isHidden = true
        setupPostAuthorInfo(with: post)
        setupCaptionLabel(with: post)
        setupTimestampLabel(with: post)
    }
    
    private func setupPostAuthorInfo(with post: Post) {
        userManager.getAuthorInfo(userId: post.userId) { [weak self] (user) in
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
    
    func setupComment(with comment: Comment, at index: Int) {
        selectionStyle = .none
        currentComment = comment
        self.index = index
        lineView.isHidden = true
        setupCommentAuthorInfo(with: comment)
        setupContentLabel(with: comment)
        setupTimestampLabel(with: comment)
        setupLikeButton(with: comment)
        enableLongPress(sender: self, select: #selector(presentAlert))
    }
    
    private func setupCommentAuthorInfo(with comment: Comment) {
        userManager.getAuthorInfo(userId: comment.userId) { [weak self] (user) in
            self?.currentUser = user
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
    
    private func configureLikeCount(with comment: Comment) {
        let count = comment.userDidLike.filter { $0 != "" }.count
        switch count {
        case 0:
            self.likeButton.setTitle("", for: .normal)
        default:
            self.likeButton.setTitle(" \(count)", for: .normal)
        }
    }
    
    private func setupLikeButton(with comment: Comment) {
        guard let userId = userManager.currentUser?.userId else { return }
        likeButton.isSelected = comment.userDidLike.contains(userId)
        configureLikeButton()
        configureLikeCount(with: comment)
    }
    
    private func configureLikeButton() {
        let size: CGFloat = 13
        
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
    
    @objc func presentAlert() {
        guard let currentComment = self.currentComment else { return }
        guard let index = self.index else { return }
        self.delegatePresent?.presentAlert(with: currentComment, at: index)
    }
}
