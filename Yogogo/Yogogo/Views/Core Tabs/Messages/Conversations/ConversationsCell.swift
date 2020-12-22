//
//  ConversationsCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import UIKit
import Lottie
import Firebase
import Kingfisher

class ConversationsCell: UITableViewCell {

    let profileImage = UIImageView()
    
    let userFullName = UILabel()
    
    let recentMessage = UILabel()
    
    let timeLabel = UILabel()
    
    let isOnlineView = UIView()
    
    let isTypingView = UIView()
    
    let typingAnimation = AnimationView()
    
    let unreadMessageView = UIView()
    
    let unreadLabel = UILabel()
    
    let checkmark = UIImageView()
    
    var convVC: ConversationsVC!
    
    var message: Messages? {
        didSet {
            guard let message = message else { return }
            convVC.setupNoTypingCell(self)
            handleFriendInfo(message)
            convVC.observeIsUserTypingHandler(message, self)
            checkmark.image = UIImage(named: "checkmark_icon")
            handleSentMessages(message)
            let date = NSDate(timeIntervalSince1970: message.time.doubleValue)
            timeLabel.text = convVC.calendar.calculateTimePassed(date: date).uppercased()
            handleMessageType(message)
        }
    }
        
    // MARK: -
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        backgroundColor = .white
        backgroundColor = .systemBackground
        setupImage()
        setupNameLabel()
        setupUnreadMessagesView()
        setupRecentMessage()
        setupTimeLabel()
        setupIsOnlineImage()
        setupUserTypingView()
        setupUnreadMessagesView()
        setupCheckmark()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func handleFriendInfo(_ message: Messages) {
        for user in Users.list {
            if message.determineUser() == user.userId {
                userFullName.text = user.fullName
                
                let url = URL(string: user.profileImage)
                profileImage.kf.setImage(with: url)
                
                isOnlineView.isHidden = !(user.isOnline)
            }
        }
    }
    
    // MARK: -
    
    private func handleSentMessages(_ message: Messages) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if message.sender == userId {
            Database.database().reference().child("messages").child("unread-Messages").child(message.determineUser()).child(userId).removeAllObservers()
            convVC.observeIsUserSeenMessage(message, self)
            checkmark.isHidden = false
        } else {
            checkmark.isHidden = true
        }
    }
    
    // MARK: -
    
    private func handleMessageType(_ message: Messages) {
        if message.mediaUrl != nil || message.videoUrl != nil {
            recentMessage.text = "[Media Message]"
        } else if message.audioUrl != nil {
            recentMessage.text = "[Audio Message]"
        } else {
            recentMessage.text = message.message
        }
    }
    
    // MARK: -
    
    private func setupIsOnlineImage() {
        addSubview(isOnlineView)
        isOnlineView.isHidden = true
        isOnlineView.layer.cornerRadius = 8
        isOnlineView.layer.borderColor = UIColor.white.cgColor
        isOnlineView.layer.borderWidth = 2.5
        isOnlineView.layer.masksToBounds = true
        isOnlineView.backgroundColor = UIColor(displayP3Red: 90/255, green: 180/255, blue: 55/255, alpha: 1)
        isOnlineView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            isOnlineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 55),
            isOnlineView.widthAnchor.constraint(equalToConstant: 16),
            isOnlineView.heightAnchor.constraint(equalToConstant: 16),
            isOnlineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
        ]
        NSLayoutConstraint.activate(constraints)
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
    
    private func setupRecentMessage() {
        addSubview(recentMessage)
        recentMessage.textColor = .lightGray
        recentMessage.font = UIFont(name: "Helvetica Neue", size: 16)
        recentMessage.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            recentMessage.centerYAnchor.constraint(equalTo: centerYAnchor),
            recentMessage.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15),
            recentMessage.trailingAnchor.constraint(equalTo: unreadMessageView.leadingAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.font = UIFont.boldSystemFont(ofSize: 11)
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 0
        timeLabel.textColor = .lightGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupNameLabel() {
        addSubview(userFullName)
        userFullName.textColor = .label
        userFullName.font = UIFont(name: "Helvetica Neue", size: 18)
        userFullName.numberOfLines = 0
        userFullName.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userFullName.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            userFullName.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupUserTypingView() {
        isTypingView.isHidden = true
        let typingText = UILabel()
        typingText.font = UIFont.boldSystemFont(ofSize: 12)
        typingText.textColor = .gray
        typingText.text = "TYPING"
        isTypingView.backgroundColor = .clear
        isTypingView.layer.cornerRadius = 12.5
        isTypingView.layer.masksToBounds = true
        addSubview(isTypingView)
        isTypingView.addSubview(typingText)
        isTypingView.addSubview(typingAnimation)
        isTypingView.translatesAutoresizingMaskIntoConstraints = false
        typingAnimation.translatesAutoresizingMaskIntoConstraints = false
        typingText.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            isTypingView.widthAnchor.constraint(equalToConstant: 100),
            isTypingView.heightAnchor.constraint(equalToConstant: 25),
            isTypingView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            isTypingView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            typingText.widthAnchor.constraint(equalToConstant: 50),
            typingText.heightAnchor.constraint(equalToConstant: 25),
            typingText.centerYAnchor.constraint(equalTo: isTypingView.centerYAnchor, constant: 5),
            typingText.trailingAnchor.constraint(equalTo: isTypingView.trailingAnchor),
            typingAnimation.leadingAnchor.constraint(equalTo: isTypingView.leadingAnchor, constant: 0),
            typingAnimation.bottomAnchor.constraint(equalTo: isTypingView.bottomAnchor),
            typingAnimation.topAnchor.constraint(equalTo: isTypingView.topAnchor),
            typingAnimation.trailingAnchor.constraint(equalTo: typingText.leadingAnchor, constant: -2)
        ]
        NSLayoutConstraint.activate(constraints)
        typingAnimation.animationSpeed = 1.5
        typingAnimation.animation = Animation.named("recentTyping")
        typingAnimation.play()
        typingAnimation.backgroundBehavior = .pauseAndRestore
        typingAnimation.loopMode = .loop
    }
    
    // MARK: -
    
    private func setupUnreadMessagesView() {
        addSubview(unreadMessageView)
        unreadMessageView.isHidden = true
        unreadMessageView.translatesAutoresizingMaskIntoConstraints = false
        unreadMessageView.backgroundColor = .systemRed
        unreadMessageView.layer.cornerRadius = 10
        unreadMessageView.layer.masksToBounds = true
        unreadMessageView.addSubview(unreadLabel)
        unreadLabel.translatesAutoresizingMaskIntoConstraints = false
        unreadLabel.font = UIFont(name: "Helvetica Neue", size: 14)
        unreadLabel.textColor = .white
        let constraints = [
            unreadMessageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            unreadMessageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            unreadMessageView.widthAnchor.constraint(equalToConstant: 20),
            unreadMessageView.heightAnchor.constraint(equalToConstant: 20),
            unreadLabel.centerXAnchor.constraint(equalTo: unreadMessageView.centerXAnchor),
            unreadLabel.centerYAnchor.constraint(equalTo: unreadMessageView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupCheckmark() {
        addSubview(checkmark)
        checkmark.isHidden = true
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.image = UIImage(named: "checkmark_icon")
        checkmark.contentMode = .scaleAspectFit
        checkmark.tintColor = .label
        let constraints = [
            checkmark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmark.heightAnchor.constraint(equalToConstant: 18),
            checkmark.widthAnchor.constraint(equalToConstant: 18)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}
