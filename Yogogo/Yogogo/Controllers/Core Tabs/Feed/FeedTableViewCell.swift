//
//  FeedTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.layer.masksToBounds = true
            profileImage.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var likeCount: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var viewCommentButton: UIButton!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    static let identifier = "FeedTableViewCell"
    
    private var currentPost: Post?
    
    let userManager = UserManager.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(post: Post) {

        // Set current post
        currentPost = post
        
        // Set the cell style
        selectionStyle = .none

        // Get post's author info from DB
        userManager.getAuthorInfo(userId: post.userId) { (user) in
            self.usernameButton.setTitle(user.username, for: .normal)

            self.profileImage.image = nil
            let url = URL(string: user.profileImage)
            self.profileImage.kf.setImage(with: url)
        }

        // Set up
        captionLabel.text = "\(post.caption)"
        
        let stringTimestamp = String(post.timestamp / 1000)
        let date = DataClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
        
        let count = post.userDidLike.count
        if count > 1 {
            likeCount.setTitle("\(post.userDidLike.count) likes", for: .normal)
        } else {
            likeCount.setTitle("\(post.userDidLike.count) like", for: .normal)
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
