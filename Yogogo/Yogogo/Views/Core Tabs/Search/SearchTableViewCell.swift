//
//  SearchTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Kingfisher

class SearchTableViewCell: UITableViewCell {
    
    static let identifier = "SearchTableViewCell"
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
            profileImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!
    
    // MARK: -
    
    func setup(with searchResults: User) {
        
        let url = URL(string: searchResults.profileImage)
        profileImageView.kf.setImage(with: url)
        
        usernameLabel.text = searchResults.username
        
        if searchResults.fullName.isEmpty {
            nameLabel.isHidden = true
        } else {        
            nameLabel.text = searchResults.fullName
        }
        
        guard let following = UserManager.shared.currentUser?.following else { return }
        followingLabel.isHidden = !following.contains(searchResults.userId)
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
