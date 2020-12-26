//
//  PostTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/3.
//

import UIKit
import Kingfisher

protocol PostTableViewCellPresentAlertDelegate: AnyObject {
    func presentAlert(postId: String)
}

protocol PostTableViewCellPresentUserDelegate: AnyObject {
    func presentUser()
}

// MARK: -

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    
    private var currentPost: Post?
    
    private var currentUser: User?
    
    let userManager = UserManager.shared
    
    weak var delegatePresentAlert: PostTableViewCellPresentAlertDelegate?
    
    weak var delegatePresentUser: PostTableViewCellPresentUserDelegate?
    
    weak var delegateReloadView: ButtonDidTapReloadDelegate?
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.layer.masksToBounds = true
            profileImage.translatesAutoresizingMaskIntoConstraints = false
            profileImage.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var moreActionsButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton! {
        didSet {
            setupLikeButton()
        }
    }
    
    @IBOutlet weak var commentButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let image = UIImage(systemName: "message", withConfiguration: config)
            commentButton.setImage(image, for: .normal)
            commentButton.tintColor = .label
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let image = UIImage(systemName: "paperplane", withConfiguration: config)
            shareButton.setImage(image, for: .normal)
            shareButton.tintColor = .label
        }
    }
    
    @IBOutlet weak var bookmarkButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let image = UIImage(systemName: "bookmark", withConfiguration: config)
            bookmarkButton.setImage(image, for: .normal)
            bookmarkButton.tintColor = .label
        }
    }
    
    @IBOutlet weak var likeCountButton: UIButton!
    
    @IBOutlet weak var moreContentButton: UIButton!
    
    @IBOutlet weak var viewCommentButton: UIButton! {
        didSet {
            viewCommentButton.isHidden = true
        }
    }
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!

    // MARK: - @IBAction
    
    @IBAction func moreActionsButtonDidTap(_ sender: UIButton) {
        guard let postId = currentPost?.postId else { return }
        self.delegatePresentAlert?.presentAlert(postId: postId)
    }
    
    @IBAction func usernameButtonDidTap(_ sender: UIButton) {
        self.delegatePresentUser?.presentUser()
    }
    
    @IBAction func moreCaptionButtonDidTap(_ sender: UIButton) {
        captionLabel.numberOfLines = 0
        moreContentButton.isHidden = true
        delegateReloadView?.reloadView(cell: self)
    }
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        
        // Change local view
        sender.isSelected.toggle()
        setupLikeButton()
        
        // Data
        guard let currentPost = currentPost else { return }
        
        PostManager.shared.updateUserDidLike(post: currentPost)
    }
    
    // MARK: -
    
    private func setupLikeButton() {
        let size: CGFloat = 19
        
        if likeButton.isSelected {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            likeButton.setImage(image, for: .selected)
            likeButton.tintColor = .systemRed
            
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .label
        }
    }

    // MARK: -
    
    func setup(post: Post) {

        selectionStyle = .none
        
        // MARK: - Observe the post
        
        PostManager.shared.getUserPost(postId: post.postId) { [weak self] (currentPost) in
            
            self?.currentPost = currentPost
            
            // likeButton
            guard let userId = self?.userManager.currentUser?.userId else { return }
            self?.likeButton.isSelected = currentPost.userDidLike.contains(userId)
            self?.setupLikeButton()
            
            // likeCountButton
            let count = currentPost.userDidLike.count - 1
            switch count {
            case 0:
                self?.likeCountButton.isHidden = true
            case 1:
                self?.likeCountButton.isHidden = false
                self?.likeCountButton.setTitle("\(count) like", for: .normal)
            default:
                self?.likeCountButton.isHidden = false
                self?.likeCountButton.setTitle("\(count) likes", for: .normal)
            }
            
            // captionLabel
            self?.captionLabel.text = currentPost.caption
            
            // moreContentButton
            let isHidden = self?.captionLabel.numberOfLines == 0 ? true : self?.captionLabel.textCount ?? 0 <= 1
            self?.moreContentButton.isHidden = isHidden
            
            // Get post's author info from DB
            self?.userManager.getAuthorInfo(userId: currentPost.userId) { [weak self] (user) in
                self?.usernameButton.setTitle(user.username, for: .normal)

                let url = URL(string: user.profileImage)
                self?.profileImage.kf.setImage(with: url)
                
                self?.currentUser = user
            }
            
            // Get post's image
            let url = URL(string: currentPost.imageFileURL)
            self?.postImageView.kf.setImage(with: url)
            
            // timestampLabel
            let stringTimestamp = String(currentPost.timestamp / 1000)
            let date = DateClass.compareCurrentTime(str: stringTimestamp)
            self?.timestampLabel.text = "\(date)"
        }
    }
}
