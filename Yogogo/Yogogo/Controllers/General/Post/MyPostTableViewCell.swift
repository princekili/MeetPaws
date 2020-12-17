//
//  PostTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/3.
//

import UIKit
import Kingfisher

protocol MyPostTableViewCellPresentAlertDelegate: AnyObject {
    
    func presentAlert(postId: String)
}

class MyPostTableViewCell: UITableViewCell {
    
    static let identifier = "MyPostTableViewCell"
    
    private var currentPost: Post?
    
    weak var delegate: MyPostTableViewCellPresentAlertDelegate?
    
    // MARK: -
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.layer.masksToBounds = true
            profileImage.translatesAutoresizingMaskIntoConstraints = false
            
            guard let imageUrl = UserManager.shared.currentUser?.profileImage else { return }
            let url = URL(string: imageUrl)
            profileImage.kf.setImage(with: url)
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton! {
        didSet {
            guard let username = UserManager.shared.currentUser?.username else { return }
            usernameButton.setTitle(username, for: .normal)
        }
    }
    
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
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var viewCommentButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!

    // MARK: - @IBAction
    
    @IBAction func moreActionsButtonDidTap(_ sender: UIButton) {
        guard let postId = currentPost?.postId else { return }
        self.delegate?.presentAlert(postId: postId)
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: -
    
    func setup(post: Post) {

        selectionStyle = .none
        
        currentPost = post
        
        postImageView.image = nil
        let url = URL(string: post.imageFileURL)
        postImageView.kf.setImage(with: url)
        
        captionLabel.text = post.caption
        
        let stringTimestamp = String(post.timestamp / 1000)
        let date = DataClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
        
        let count = post.userDidLike.count - 1
        if count > 1 {
            likeCount.setTitle("\(count) likes", for: .normal)
        } else {
            likeCount.setTitle("\(count) like", for: .normal)
        }
    }
}

