//
//  FeedTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Kingfisher

protocol FeedTableViewCellPresentAlertDelegate: AnyObject {
    
    func presentAlert(postId: String, at index: Int)
}

protocol FeedTableViewCellPresentUserDelegate: AnyObject {
    
    func presentUser(user: User, at index: Int)
}

protocol LikeButtonDidTapDelegate: AnyObject {
    
    func reloadView(cell: UITableViewCell)
}

class FeedTableViewCell: UITableViewCell {
    
    static let identifier = "FeedTableViewCell"
    
    private var currentPost: Post?
    
    private var currentUser: User?
    
    let userManager = UserManager.shared
    
    weak var delegatePresentAlert: FeedTableViewCellPresentAlertDelegate?
    
    weak var delegatePresentUser: FeedTableViewCellPresentUserDelegate?
    
    weak var delegateReloadView: LikeButtonDidTapDelegate?
    
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
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            let image = UIImage(systemName: "heart", withConfiguration: config)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = .label
        }
    }
    
    @IBOutlet weak var messageButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let image = UIImage(systemName: "message", withConfiguration: config)
            messageButton.setImage(image, for: .normal)
            messageButton.tintColor = .label
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
    
    @IBOutlet weak var likeCount: UIButton!
    
    @IBOutlet weak var moreContentButton: UIButton! {
        didSet {
            moreContentButton.isHidden = true
        }
    }
    
    @IBOutlet weak var viewCommentButton: UIButton! {
        didSet {
            viewCommentButton.isHidden = true
        }
    }
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    // MARK: - @IBAction
    
    @IBAction func moreActionsButtonDidTap(_ sender: UIButton) {
        guard let postId = currentPost?.postId else { return }
        self.delegatePresentAlert?.presentAlert(postId: postId, at: sender.tag)
    }
    
    @IBAction func usernameButtonDidTap(_ sender: UIButton) {
        guard let user = currentUser else { return }
        self.delegatePresentUser?.presentUser(user: user, at: sender.tag)
    }
    
//    var isLiked: Bool = false {
//        didSet {
//            if isLiked {
//                self.likeButton.backgroundColor = .red
//            } else {
//                self.likeButton.backgroundColor = .blue
//            }
//        }
//    }
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        
        // Data
        guard let post = currentPost,
              let delegate = delegateReloadView
        else {
            print("------ post or delegate is nil in FeedTableViewCell")
            return
        }
        
//        isLiked = !isLiked
        
        PostManager.shared.updateUserDidLike(post: post) {
            // View
            sender.isSelected = !sender.isSelected
            delegate.reloadView(cell: self)
        }
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Set up posts

extension FeedTableViewCell {
    
    func setup(post: Post, at index: Int) {

        // Set index
        moreActionsButton.tag = index
        
        // Set current post
        currentPost = post
        
        // Set the cell style
        selectionStyle = .none

        // Get post's author info from DB
        userManager.getAuthorInfo(userId: post.userId) { [weak self] (user) in
            self?.usernameButton.setTitle(user.username, for: .normal)

            self?.profileImage.image = nil
            let url = URL(string: user.profileImage)
            self?.profileImage.kf.setImage(with: url)
            
            self?.currentUser = user
        }

        // Set up
        captionLabel.text = post.caption
        
        let stringTimestamp = String(post.timestamp / 1000)
        let date = DateClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
        
        let count = post.userDidLike.count - 1
        if count > 1 {
            likeCount.setTitle("\(count) likes", for: .normal)
        } else {
            likeCount.setTitle("\(count) like", for: .normal)
        }
        
        // Reset image view's image
        postImageView.image = nil
        
        // likeButton
        guard let userId = userManager.currentUser?.userId else { return }
        likeButton.isSelected = post.userDidLike.contains(userId)
        
        // MARK: - Download post image - KingFisher
        let url = URL(string: post.imageFileURL)
        postImageView.kf.setImage(with: url)
    }
}
