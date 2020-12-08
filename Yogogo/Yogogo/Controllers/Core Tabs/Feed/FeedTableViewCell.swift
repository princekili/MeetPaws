//
//  FeedTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = profileImageButton.frame.size.width / 2
            profileImageButton.layer.masksToBounds = true
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

        // Set up
        usernameButton.setTitle(post.username, for: .normal)
//        profileImageButton.setTitle(post.userProfileImage, for: .normal)
        likeCount.setTitle("\(post.userDidLike.count) likes", for: .normal)
        captionLabel.text = "\(Data())"
        
        // Reset image view's image
        postImageView.image = nil
        
        let url = URL(string: post.imageFileURL)
        postImageView.kf.setImage(with: url)
        
        // Download post image
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
