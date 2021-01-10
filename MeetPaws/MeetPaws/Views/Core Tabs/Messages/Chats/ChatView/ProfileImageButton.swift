//
//  ProfileImageButton.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit
import Kingfisher

class ProfileImageButton: UIButton {

    init(chatVC: ChatVC, url: String) {
        super.init(frame: .zero)
        setupProfileImage(url, chatVC)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func setupProfileImage(_ url: String, _ chatVC: ChatVC) {
        let userImageIcon = UIImageView()
        
        let url = URL(string: url)
        userImageIcon.kf.setImage(with: url)
        
        addSubview(userImageIcon)
        userImageIcon.translatesAutoresizingMaskIntoConstraints = false
        userImageIcon.contentMode = .scaleAspectFill
        userImageIcon.layer.cornerRadius = 16
        userImageIcon.layer.masksToBounds = true
        let constraints = [
            userImageIcon.leadingAnchor.constraint(equalTo: leadingAnchor),
            userImageIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            userImageIcon.heightAnchor.constraint(equalToConstant: 32),
            userImageIcon.widthAnchor.constraint(equalToConstant: 32)
        ]
        NSLayoutConstraint.activate(constraints)
        addTarget(chatVC, action: #selector(chatVC.profileImageTapped), for: .touchUpInside)
    }
}
