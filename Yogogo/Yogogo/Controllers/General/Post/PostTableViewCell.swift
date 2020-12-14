//
//  PostTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/3.
//

import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    
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
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    @IBOutlet weak var likeCount: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var viewCommentButton: UIButton!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
