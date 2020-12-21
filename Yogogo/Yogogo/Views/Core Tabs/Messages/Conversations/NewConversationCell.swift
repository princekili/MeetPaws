//
//  NewConversationCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import UIKit

class NewConversationCell: UITableViewCell {

    let profileImage = UIImageView()
    
    let userFullName = UILabel()
    
    let username = UILabel()
    
    // MARK: -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupImage()
        setupFullNameLabel()
        setupUsernameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func setupImage() {
        addSubview(profileImage)
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 30
        profileImage.layer.masksToBounds = true
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            profileImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            profileImage.heightAnchor.constraint(equalToConstant: 60),
            profileImage.widthAnchor.constraint(equalToConstant: 60)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupFullNameLabel() {
        addSubview(userFullName)
        userFullName.textColor = .label
        userFullName.numberOfLines = 0
        userFullName.adjustsFontSizeToFitWidth = true
        userFullName.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userFullName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            userFullName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupUsernameLabel() {
        addSubview(username)
        username.numberOfLines = 0
        username.adjustsFontSizeToFitWidth = true
        username.textColor = .gray
        username.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            username.topAnchor.constraint(equalTo: userFullName.bottomAnchor, constant: 0),
            username.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
