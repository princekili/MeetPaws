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

class FeedTableViewCell: UITableViewCell {
    
    static let identifier = "FeedTableViewCell"
    
    private var currentPost: Post?
    
    let userManager = UserManager.shared
    
    weak var delegate: FeedTableViewCellPresentAlertDelegate?
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.layer.masksToBounds = true
            profileImage.translatesAutoresizingMaskIntoConstraints = false
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
    
    @IBOutlet weak var moreContentButton: UIButton!
    
    @IBOutlet weak var viewCommentButton: UIButton!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    // MARK: - @IBAction
    
    @IBAction func moreActionsButtonDidTap(_ sender: UIButton) {
        guard let postId = currentPost?.postId else { return }
        self.delegate?.presentAlert(postId: postId, at: sender.tag)
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
        }

        // Set up
        captionLabel.text = "\(post.caption)"
        
        let stringTimestamp = String(post.timestamp / 1000)
        let date = DataClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
        
        let count = post.userDidLike.count - 1
        if count > 1 {
            likeCount.setTitle("\(count) likes", for: .normal)
        } else {
            likeCount.setTitle("\(count) like", for: .normal)
        }
        
        // Reset image view's image
        postImageView.image = nil
        
        // MARK: - Download post image - KingFisher
        let url = URL(string: post.imageFileURL)
        postImageView.kf.setImage(with: url)
        
        // MARK: - Download post image - URLSession
//        if let image = CacheManager.shared.getFromCache(key: post.imageFileURL) as? UIImage {
//            postImageView.image = image
//
//        } else {
//            if let url = URL(string: post.imageFileURL) {
//
//                let downloadTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//
//                    guard let imageData = data else {
//                        return
//                    }
//
//                    OperationQueue.main.addOperation {
//                        guard let image = UIImage(data: imageData) else { return }
//
//                        if self.currentPost?.imageFileURL == post.imageFileURL {
//                            self.postImageView.image = image
//                        }
//
//                        // Add the downloaded image to cache
//                        CacheManager.shared.cache(object: image, key: post.imageFileURL)
//                    }
//
//                })
//
//                downloadTask.resume()
//            }
//        }
    }
}
