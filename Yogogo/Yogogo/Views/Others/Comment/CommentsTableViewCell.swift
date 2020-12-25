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
    
    private var currentComment: Comment?
    
    private var currentUser: User?
    
    let userManager = UserManager.shared
    
    // MARK: - @IBOutlet for cell

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    // MARK: -
    
    func setup(with comment: Comment, index: Int) {
        
        // Set current post
        currentComment = comment
        
        // Set the cell style
        selectionStyle = .none

        // Get post's author info from DB
        userManager.getAuthorInfo(userId: comment.userId) { [weak self] (user) in
            self?.usernameButton.setTitle(user.username, for: .normal)

            let url = URL(string: user.profileImage)
            self?.profileImage.kf.setImage(with: url)
            
            self?.currentUser = user
        }

        if index == 0 {
            // Get the post caption via postId
//            contentLabel.text = post.caption
        } else {
            contentLabel.text = comment.content
        }
        
        let stringTimestamp = String(comment.timestamp / 1000)
        let date = DateClass.compareCurrentTime(str: stringTimestamp)
        timestampLabel.text = "\(date)"
        
        let count = comment.userDidLike.count - 1
        if count > 1 {
            likeCountLabel.text = "\(count) likes"
        } else {
            likeCountLabel.text = "\(count) like"
        }
        
        // likeButton
        guard let userId = userManager.currentUser?.userId else { return }
        likeButton.isSelected = comment.userDidLike.contains(userId)
    }
    
    // MARK: -
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
}
