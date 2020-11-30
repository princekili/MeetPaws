//
//  SearchTableViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageButton: UIButton! {
        didSet {
            profileImageButton.layer.cornerRadius = 36 / 2
            profileImageButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var nameButton: UIButton!
    
    static let identifier = "SearchTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
