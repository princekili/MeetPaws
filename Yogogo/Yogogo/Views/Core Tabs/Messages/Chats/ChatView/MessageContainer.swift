//
//  MessageContainer.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//
// MARK: MessageContainer - input view that is located at the bottom of ChatVC.

import UIKit
import Lottie

class MessageContainer: UIView, UITextViewDelegate {
    
    var bottomAnchr = NSLayoutConstraint()
    
    var heightAnchr = NSLayoutConstraint()
    
    let addImageButton = UIButton(type: .system)
    
    let sendButton = UIButton(type: .system)
    
    let micButton = UIButton(type: .system)
    
    let messageTextView = UITextView()
    
    let recordingAudioView = AnimationView()
    
    let recordingLabel = UILabel()
    
    let actionCircle = UIView()
    
    var containerHeight: CGFloat!
    
    var const: CGFloat!
    
    let size: CGFloat = 30
    
    var chatVC: ChatVC!
    
    // MARK: -
    
    init(height: CGFloat, const: CGFloat, chatVC: ChatVC) {
        super.init(frame: .zero)
        self.chatVC = chatVC
        self.containerHeight = height
        self.const = const
        setupMessageContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func setupMessageContainer() {
        setupBackground()
        setupAddImageButton()
        setupSendButton()
        setupMessageTV()
//        setupActionCircle()
//        setupMicrophone()
//        recordingAudioAnimation()
//        setupRecordingLabel()
    }
    
    // MARK: -
    
    private func setupBackground() {
        chatVC.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
//        backgroundColor = .systemGray6
        backgroundColor = .systemBackground
        bottomAnchr = bottomAnchor.constraint(equalTo: chatVC.view.bottomAnchor)
        heightAnchr = heightAnchor.constraint(equalToConstant: containerHeight)
        let constraints = [
            leadingAnchor.constraint(equalTo: chatVC.view.leadingAnchor),
            bottomAnchr,
            heightAnchr,
            trailingAnchor.constraint(equalTo: chatVC.view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupAddImageButton() {
        addImageButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addSubview(addImageButton)
        addImageButton.tintColor = .label
        addImageButton.contentMode = .scaleAspectFill
        addImageButton.isEnabled = true
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            addImageButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            addImageButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const),
            addImageButton.widthAnchor.constraint(equalToConstant: size),
            addImageButton.heightAnchor.constraint(equalToConstant: size)
        ]
        addImageButton.addTarget(chatVC, action: #selector(chatVC.addImageButtonPressed), for: .touchUpInside)
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupSendButton() {
        addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.alpha = 0
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "arrow.up", withConfiguration: config)
        sendButton.setImage(image, for: .normal)
        sendButton.backgroundColor = ThemeColors.selectedOutcomingColor
        sendButton.layer.cornerRadius = size / 2
        sendButton.layer.masksToBounds = true
        sendButton.tintColor = .white
        let constraints = [
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.heightAnchor.constraint(equalToConstant: size),
            sendButton.widthAnchor.constraint(equalToConstant: size)
        ]
        NSLayoutConstraint.activate(constraints)
        sendButton.addTarget(chatVC, action: #selector(chatVC.sendButtonPressed), for: .touchUpInside)
    }
    
    // MARK: -
    
    private func setupMessageTV() {
        addSubview(messageTextView)
        messageTextView.layer.cornerRadius = 14
        messageTextView.font = UIFont(name: "Helvetica Neue", size: 16)
        messageTextView.textColor = .label
        messageTextView.isScrollEnabled = false
        messageTextView.layer.borderWidth = 0.5
        messageTextView.layer.borderColor = UIColor.systemGray.cgColor
        messageTextView.layer.masksToBounds = true
        let msgTVPlaceholder = UILabel()
        msgTVPlaceholder.text = "Message"
        msgTVPlaceholder.font = UIFont(name: "Helvetica Neue", size: 16)
        msgTVPlaceholder.sizeToFit()
        messageTextView.addSubview(msgTVPlaceholder)
        msgTVPlaceholder.frame.origin = CGPoint(x: 10, y: 6)
        msgTVPlaceholder.textColor = .lightGray
        messageTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10)
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.backgroundColor = .systemBackground
        messageTextView.adjustsFontForContentSizeCategory = true
        messageTextView.delegate = self
        let constraints = [
            messageTextView.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor, constant: 8),
            messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const),
            messageTextView.heightAnchor.constraint(equalToConstant: size)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
//    private func setupMicrophone() {
//        addSubview(micButton)
//        micButton.translatesAutoresizingMaskIntoConstraints = false
//        micButton.setImage(UIImage(systemName: "mic"), for: .normal)
//        micButton.tintColor = .label
//        micButton.addTarget(chatVC, action: #selector(chatVC.handleAudioRecording), for: .touchUpInside)
//        let constraints = [
//            micButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const),
//            micButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            micButton.heightAnchor.constraint(equalToConstant: 30),
//            micButton.widthAnchor.constraint(equalToConstant: 30)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
    
    // MARK: -
    
//    private func recordingAudioAnimation() {
//        recordingAudioView.isHidden = true
//        addSubview(recordingAudioView)
//        recordingAudioView.animation = Animation.named("audioWave")
//        recordingAudioView.play()
//        recordingAudioView.loopMode = .loop
//        recordingAudioView.backgroundBehavior = .pauseAndRestore
//        recordingAudioView.translatesAutoresizingMaskIntoConstraints = false
//        let constraints = [
//            recordingAudioView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            recordingAudioView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            recordingAudioView.heightAnchor.constraint(equalToConstant: 180),
//            recordingAudioView.widthAnchor.constraint(equalToConstant: 180)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
    
    // MARK: -
    
//    private func setupRecordingLabel() {
//        addSubview(recordingLabel)
//        recordingLabel.isHidden = true
//        recordingLabel.text = "00:00"
//        recordingLabel.translatesAutoresizingMaskIntoConstraints = false
//        recordingLabel.font = UIFont(name: "Helvetica Neue", size: 16)
//        let constraints = [
//            recordingLabel.trailingAnchor.constraint(equalTo: leadingAnchor),
//            recordingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const - 5)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
    
    // MARK: -
    
    private func setupActionCircle() {
        addSubview(actionCircle)
        actionCircle.isHidden = true
        actionCircle.translatesAutoresizingMaskIntoConstraints = false
        actionCircle.backgroundColor = .systemBackground
        actionCircle.layer.cornerRadius = 3
        actionCircle.layer.masksToBounds = true
        let constraints = [
            actionCircle.heightAnchor.constraint(equalToConstant: 6),
            actionCircle.widthAnchor.constraint(equalToConstant: 6),
            actionCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            actionCircle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -const - 10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MessageContainer {

    func textViewDidEndEditing(_ textView: UITextView) {
        chatVC.chatNetworking.disableIsTyping()
    }
    
    // MARK: -
    
    func textViewDidChange(_ textView: UITextView) {
        chatVC.chatNetworking.isTypingHandler(textView: textView)
        chatVC.animateActionButton()
        messageTextView.subviews[2].isHidden = !messageTextView.text.isEmpty
        let size = CGSize(width: textView.frame.width, height: 150)
        let estSize = textView.sizeThatFits(size)
        messageTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute != .height { return }
            chatVC.messageHeightHandler(constraint, estSize)
            chatVC.messageContainerHeightHandler(heightAnchr, estSize)
        }
    }
}
