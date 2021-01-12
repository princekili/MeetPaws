//
//  ChatVC + Extension.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit
import Kingfisher

extension ChatViewController {

    func responseViewChangeAlpha(alpha: CGFloat) {
        userResponse.lineView.alpha = alpha
        userResponse.nameLabel.alpha = alpha
        userResponse.messageLabel.alpha = alpha
        userResponse.mediaMessage.alpha = alpha
        userResponse.exitButton.alpha = alpha
        userResponse.audioMessage.alpha = alpha
    }
    
    // MARK: -
    
    func responseMessageLine(_ message: Messages, _ userName: String?) {
        userResponse.lineView.backgroundColor = .label
        userResponse.lineView.layer.cornerRadius = 1
        userResponse.lineView.layer.masksToBounds = true
        messageContainer.addSubview(userResponse.lineView)
        userResponse.lineView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            userResponse.lineView.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
            userResponse.lineView.bottomAnchor.constraint(equalTo: messageContainer.messageTextView.topAnchor, constant: -8),
            userResponse.lineView.leadingAnchor.constraint(equalTo: messageContainer.messageTextView.leadingAnchor, constant: 8),
            userResponse.lineView.widthAnchor.constraint(equalToConstant: 2)
        ]
        NSLayoutConstraint.activate(constraints)
        setupExitResponseButton()
        if let userName = userName {
            responseMessageName(for: message, userName)
        } else {
            chatNetworking.getMessageSender(message: message) { (sender) in
                self.responseMessageName(for: message, sender)
            }
        }
    }
    
    // MARK: -
    
    func setupExitResponseButton() {
        messageContainer.addSubview(userResponse.exitButton)
        userResponse.exitButton.translatesAutoresizingMaskIntoConstraints = false
        userResponse.exitButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        userResponse.exitButton.tintColor = .label
        let constraints = [
            userResponse.exitButton.trailingAnchor.constraint(equalTo: messageContainer.messageTextView.trailingAnchor, constant: -16),
            userResponse.exitButton.centerYAnchor.constraint(equalTo: userResponse.lineView.centerYAnchor),
            userResponse.exitButton.widthAnchor.constraint(equalToConstant: 14),
            userResponse.exitButton.heightAnchor.constraint(equalToConstant: 14)
        ]
        userResponse.exitButton.addTarget(self, action: #selector(exitResponseButtonPressed), for: .touchUpInside)
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    @objc func  exitResponseButtonPressed() {
        userResponse.responseStatus = false
        userResponse.repliedMessage = nil
        userResponse.messageToForward = nil
        userResponse.messageSender = nil
        
        messageContainer.heightAnchr.constant -= 50
        
        messageContainer.micButton.alpha = 1
        messageContainer.sendButton.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.userResponse.lineView.removeFromSuperview()
            self.userResponse.exitButton.removeFromSuperview()
            self.userResponse.nameLabel.removeFromSuperview()
            self.userResponse.mediaMessage.removeFromSuperview()
            self.userResponse.messageLabel.removeFromSuperview()
            self.userResponse.audioMessage.removeFromSuperview()
        }
        
    }
    
    // MARK: -
    
    func responseMessageName(for message: Messages, _ name: String) {
        userResponse.messageSender = name
        messageContainer.addSubview(userResponse.nameLabel)
        userResponse.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        userResponse.nameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        userResponse.nameLabel.textColor = .label
        userResponse.nameLabel.text = name
        userResponse.nameLabelConstraint = userResponse.nameLabel.leadingAnchor.constraint(equalTo: userResponse.lineView.trailingAnchor, constant: 8)
        let constraints = [
            userResponse.nameLabelConstraint!,
            userResponse.nameLabel.trailingAnchor.constraint(equalTo: userResponse.exitButton.trailingAnchor, constant: -8),
            userResponse.nameLabel.topAnchor.constraint(equalTo: userResponse.lineView.topAnchor, constant: 4)
        ]
        NSLayoutConstraint.activate(constraints)
        setupResponseMessage(message)
    }
    
    // MARK: -
    
    func setupResponseMessage(_ message: Messages) {
        if message.mediaUrl != nil {
            setupResponseMediaM(message)
        } else {
            setupResponseTextM(message)
        }
    }
    
    // MARK: -
    
    func setupResponseTextM(_ message: Messages) {
        messageContainer.addSubview(userResponse.messageLabel)
        userResponse.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        userResponse.messageLabel.font = UIFont(name: "Helvetica Neue", size: 15)
        userResponse.messageLabel.textColor = .label
        userResponse.messageLabel.text = message.message
        let constraints = [
            userResponse.messageLabel.leadingAnchor.constraint(equalTo: userResponse.lineView.trailingAnchor, constant: 8),
            userResponse.messageLabel.trailingAnchor.constraint(equalTo: userResponse.exitButton.trailingAnchor, constant: -16),
            userResponse.messageLabel.topAnchor.constraint(equalTo: userResponse.nameLabel.bottomAnchor),
            userResponse.messageLabel.bottomAnchor.constraint(equalTo: messageContainer.messageTextView.topAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    func setupResponseMediaM(_ message: Messages) {
        let replyMediaLabel = UILabel()
        replyMediaLabel.text = "Media"
        replyMediaLabel.textColor = .lightGray
        replyMediaLabel.font = UIFont(name: "Helvetica Neue", size: 15)
        messageContainer.addSubview(userResponse.mediaMessage)
        userResponse.mediaMessage.translatesAutoresizingMaskIntoConstraints = false
        userResponse.mediaMessage.addSubview(replyMediaLabel)
        replyMediaLabel.translatesAutoresizingMaskIntoConstraints = false
        let url = URL(string: message.mediaUrl)
        userResponse.mediaMessage.kf.setImage(with: url)
        userResponse.nameLabelConstraint.constant += 34
        let constraints = [
            userResponse.mediaMessage.topAnchor.constraint(equalTo: userResponse.lineView.topAnchor, constant: 2),
            userResponse.mediaMessage.bottomAnchor.constraint(equalTo: userResponse.lineView.bottomAnchor, constant: -2),
            userResponse.mediaMessage.widthAnchor.constraint(equalToConstant: 30),
            userResponse.mediaMessage.leadingAnchor.constraint(equalTo: userResponse.lineView.trailingAnchor, constant: 4),
            replyMediaLabel.centerYAnchor.constraint(equalTo: userResponse.mediaMessage.centerYAnchor, constant: 8),
            replyMediaLabel.leadingAnchor.constraint(equalTo: userResponse.mediaMessage.trailingAnchor, constant: 8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
