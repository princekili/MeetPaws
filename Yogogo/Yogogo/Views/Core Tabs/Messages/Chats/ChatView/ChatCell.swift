//
//  ChatCell.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit
import AVFoundation
import Kingfisher

class ChatCell: UICollectionViewCell {
    
    let message = UILabel()
    
    let messageBackground = UIView()
    
    let mediaMessage = UIImageView()
    
    var chatVC: ChatVC!
    
    var msgTopAnchor: NSLayoutConstraint!
    
    var replyMsgTopAnchor: NSLayoutConstraint!
    
    var backgroundWidthAnchor: NSLayoutConstraint!
    
    var outcomingMessage: NSLayoutConstraint!
    
    var incomingMessage: NSLayoutConstraint!
    
    let activityLabel = UILabel()
    
    let timeLabel = UILabel()
    
    let playButton = UIButton(type: .system)
    
    var playerLayer: AVPlayerLayer?
    
    var videoPlayer: AVPlayer?
    
    var activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    let audioPlayButton = UIButton(type: .system)
    
    let durationLabel = UILabel()
    
    var audioPlayer: AVAudioPlayer!
    
    var timer: Timer!
    
    var msg: Messages? {
        didSet {
            if let message = msg?.message {
                backgroundWidthAnchor.constant = chatVC.calculateFrameInText(message: message).width + 32
            }
            setupMessagePosition(msg)
            setupImageMessage(msg)
            playButton.isHidden = msg?.videoUrl == nil
            
            // MARK: - setupAudioMessage
            setupAudioMessage(msg)
            
            if msg?.repMID != nil {
                setupRepMessageView(msg!.repSender)
            } else {
                removeReplyOutlets()
            }
            
            guard let currentUser = UserManager.shared.currentUser else { return }
            
            if msg?.sender == currentUser.userId && msg?.id == chatVC.messages.last?.id {
                activityLabel.isHidden = false
                activityLabel.text = chatVC.chatNetworking.messageStatus
            } else {
                activityLabel.isHidden = true
            }
            
            if let time = msg?.time {
                let messageDate = NSDate(timeIntervalSince1970: time.doubleValue)
                timeLabel.text = "⏱ " + chatVC.calendar.calculateTimePassed(date: messageDate).uppercased()
            }
        }
    }
    
    var isIncoming: Bool! {
        didSet {
            messageBackground.backgroundColor = isIncoming ? ThemeColors.selectedBackgroundColor : ThemeColors.selectedOutcomingColor
            message.textColor = isIncoming ? ThemeColors.selectedIncomingTextColor : ThemeColors.selectedOutcomingTextColor
            let userColor = isIncoming ? ThemeColors.selectedOutcomingColor : ThemeColors.selectedIncomingColor
            responseLine.backgroundColor = userColor
            responseNameLabel.textColor = userColor
            responseTextMessage.textColor = userColor
            audioPlayButton.tintColor = userColor
            durationLabel.textColor = userColor
        }
    }
    
    // MARK: -
    
    // Reply Outlets
    let responseView = UIView()
    
    let responseLine = UIView()
    
    let responseNameLabel = UILabel()
    
    let responseTextMessage = UILabel()
    
    let responseMediaMessage = UIImageView()
    
    let responseAudioMessage = UILabel()
    
    // MARK: -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        addSubview(messageBackground)
        setupBackgroundView()
        setupMessage()
        setupMediaMessage()
        setupActivityLabel()
        setupPlayButton()
        setupActivityIndicator()
        setupTimeLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        videoPlayer?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func setupMessagePosition(_ msg: Messages?) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        if msg?.recipient == currentUser.userId {
            isIncoming = true
            outcomingMessage.isActive = false
            incomingMessage.isActive = true
        } else {
            isIncoming = false
            incomingMessage.isActive = false
            outcomingMessage.isActive = true
        }
    }
    
    // MARK: -
    
    private func setupImageMessage(_ msg: Messages?) {
        if msg?.mediaUrl != nil {
            
            let url = URL(string: msg!.mediaUrl)
            mediaMessage.kf.setImage(with: url)
            
            mediaMessage.isHidden = false
            backgroundWidthAnchor.constant = 200
            messageBackground.backgroundColor = .clear
        } else {
            mediaMessage.isHidden = true
        }
    }
    
    // MARK: -
    // MARK: - setupAudioMessage
    
    private func setupAudioMessage(_ msg: Messages?) {
        if msg?.audioUrl != nil {
            guard let url = URL(string: msg!.audioUrl!) else { return }
            backgroundWidthAnchor.constant = 120
            setupAudioPlayButton()
            chatVC.chatNetworking.downloadMessageAudio(with: url) { (data, eror) in
                guard let data = data else { return }
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayButton.isEnabled = true
                    let (minute, second) = self.timeFrom(seconds: Int(self.audioPlayer.duration - self.audioPlayer.currentTime))
                    let minutes = minute < 10 ? "0\(minute)" : "\(minute)"
                    let seconds = second < 10 ? "0\(second)" : "\(second)"
                    self.setupAudioDurationLabel()
                    self.durationLabel.text = "\(minutes):\(seconds)"
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            durationLabel.removeFromSuperview()
            audioPlayButton.removeFromSuperview()
        }
    }
    
    // MARK: -
    
    private func setupBackgroundView() {
        messageBackground.translatesAutoresizingMaskIntoConstraints = false
        messageBackground.layer.cornerRadius = 12
        messageBackground.layer.masksToBounds = true
        backgroundWidthAnchor = messageBackground.widthAnchor.constraint(equalToConstant: 200)
        let constraints = [
            messageBackground.topAnchor.constraint(equalTo: topAnchor),
            backgroundWidthAnchor!,
            messageBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        outcomingMessage = messageBackground.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -128)
        incomingMessage = messageBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        outcomingMessage.isActive = true
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupMessage() {
        messageBackground.addSubview(message)
        message.numberOfLines = 0
        message.backgroundColor = .clear
        message.translatesAutoresizingMaskIntoConstraints = false
        message.font = UIFont(name: "Helvetica Neue", size: 16)
        msgTopAnchor = message.topAnchor.constraint(equalTo: messageBackground.topAnchor)
        replyMsgTopAnchor = message.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 50)
        let constraints = [
            message.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 16),
            message.bottomAnchor.constraint(equalTo: messageBackground.bottomAnchor),
            message.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            msgTopAnchor!
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupMediaMessage() {
        messageBackground.addSubview(mediaMessage)
        mediaMessage.translatesAutoresizingMaskIntoConstraints = false
        mediaMessage.layer.cornerRadius = 16
        mediaMessage.layer.masksToBounds = true
        mediaMessage.contentMode = .scaleAspectFill
        let imageTapped = UITapGestureRecognizer(target: self, action: #selector(imageTappedHandler(tap:)))
        mediaMessage.addGestureRecognizer(imageTapped)
        mediaMessage.isUserInteractionEnabled = true
        let constraints = [
            mediaMessage.topAnchor.constraint(equalTo: topAnchor),
            mediaMessage.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor),
            mediaMessage.widthAnchor.constraint(equalTo: messageBackground.widthAnchor),
            mediaMessage.heightAnchor.constraint(equalTo: messageBackground.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupActivityLabel() {
        addSubview(activityLabel)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        activityLabel.isHidden = false
        activityLabel.font = UIFont.boldSystemFont(ofSize: 11)
        activityLabel.textColor = ThemeColors.selectedOutcomingColor
//        activityLabel.textColor = .systemBackground
        let constraints = [
            activityLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -4),
            activityLabel.topAnchor.constraint(equalTo: messageBackground.bottomAnchor, constant: 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupTimeLabel() {
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.boldSystemFont(ofSize: 10)
        timeLabel.textColor = .gray
        timeLabel.numberOfLines = 0
        let constraints = [
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupActivityIndicator() {
        messageBackground.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .white
        let constraints = [
            activityIndicatorView.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: messageBackground.centerXAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupPlayButton() {
        messageBackground.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        playButton.tintColor = .white
        let constraints = [
            playButton.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: messageBackground.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 35),
            playButton.heightAnchor.constraint(equalToConstant: 35)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    @objc private func playButtonPressed() {
        if let url = URL(string: msg!.videoUrl) {
            videoPlayer = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer?.frame = messageBackground.bounds
            let tap = UITapGestureRecognizer(target: self, action: #selector(pausePlayer))
            messageBackground.isUserInteractionEnabled = true
            messageBackground.addGestureRecognizer(tap)
            messageBackground.layer.addSublayer(playerLayer!)
            videoPlayer?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    // MARK: -
    
    @objc private func pausePlayer() {
        guard msg?.videoUrl != nil else { return }
        if videoPlayer?.rate != 0 {
            videoPlayer?.pause()
        } else {
            videoPlayer?.play()
        }
    }
    
    // MARK: -
    
    @objc private func playerDidFinishPlaying() {
        activityIndicatorView.stopAnimating()
        playButton.isHidden = false
        playerLayer?.removeFromSuperlayer()
    }
    
    // MARK: -
    
    @objc private func imageTappedHandler(tap: UITapGestureRecognizer) {
        guard msg?.videoUrl == nil, msg != nil else { return }
        let imageView = tap.view as? UIImageView
        chatVC.zoomImageHandler(image: imageView!, message: msg!)
    }
    
    // MARK: -
    
    private func setupRepMessageView(_ friendName: String) {
        self.handleRepMessageSetup(friendName)
    }
    
    // MARK: -
    
    private func handleRepMessageSetup(_ name: String) {
        self.msgTopAnchor.isActive = false
        self.replyMsgTopAnchor.isActive = true
        if self.backgroundWidthAnchor.constant < 140 { self.backgroundWidthAnchor.constant = 140 }
        self.setupReplyLine()
        self.setupReplyName(name: name)
        if msg?.repMessage != nil {
            self.responseMediaMessage.removeFromSuperview()
            self.responseAudioMessage.removeFromSuperview()
            self.setupReplyTextMessage(text: msg!.repMessage)
        } else if msg?.repMediaMessage != nil {
            self.responseTextMessage.removeFromSuperview()
            self.responseAudioMessage.removeFromSuperview()
            self.setupReplyMediaMessage(msg!.repMediaMessage)
        } else {
            self.responseMediaMessage.removeFromSuperview()
            self.responseTextMessage.removeFromSuperview()
            setupResponseAudioMessage()
        }
    }
    
    // MARK: -
    
    private func setupReplyLine() {
        messageBackground.addSubview(responseLine)
        responseLine.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            responseLine.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 16),
            responseLine.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 8),
            responseLine.bottomAnchor.constraint(equalTo: message.topAnchor, constant: -2),
            responseLine.widthAnchor.constraint(equalToConstant: 2)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupReplyName(name: String) {
        responseNameLabel.text = name
        responseNameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        responseNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: -
    
    private func setupReplyTextMessage(text: String) {
        responseTextMessage.text = text
        responseTextMessage.font = UIFont(name: "Helvetica Neue", size: 15)
        messageBackground.addSubview(responseTextMessage)
        responseTextMessage.translatesAutoresizingMaskIntoConstraints = false
        responseTextMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            responseTextMessage.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseTextMessage.bottomAnchor.constraint(equalTo: responseLine.bottomAnchor, constant: -4),
            responseTextMessage.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            responseNameLabel.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseNameLabel.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseNameLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: 8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupReplyMediaMessage(_ url: String) {
        let replyMediaLabel = UILabel()
        replyMediaLabel.text = "Media"
        replyMediaLabel.font = UIFont(name: "Helvetica Neue", size: 15)
        replyMediaLabel.textColor = isIncoming ? .lightGray : .lightText
        messageBackground.addSubview(responseMediaMessage)
        responseMediaMessage.translatesAutoresizingMaskIntoConstraints = false
        responseMediaMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        responseMediaMessage.addSubview(replyMediaLabel)
        replyMediaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let url = URL(string: url)
        responseMediaMessage.kf.setImage(with: url)
        
        let constraints = [
            responseMediaMessage.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseMediaMessage.bottomAnchor.constraint(equalTo: responseLine.bottomAnchor, constant: -2),
            responseMediaMessage.widthAnchor.constraint(equalToConstant: 30),
            responseMediaMessage.leadingAnchor.constraint(equalTo: responseLine.trailingAnchor, constant: 4),
            replyMediaLabel.centerYAnchor.constraint(equalTo: responseMediaMessage.centerYAnchor, constant: 8),
            replyMediaLabel.leadingAnchor.constraint(equalTo: responseMediaMessage.trailingAnchor, constant: 4),
            responseNameLabel.leadingAnchor.constraint(equalTo: responseMediaMessage.trailingAnchor, constant: 4),
            responseNameLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            responseNameLabel.centerYAnchor.constraint(equalTo: responseMediaMessage.centerYAnchor, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupResponseAudioMessage() {
        messageBackground.addSubview(responseAudioMessage)
        responseAudioMessage.translatesAutoresizingMaskIntoConstraints = false
        responseAudioMessage.addSubview(responseNameLabel)
        responseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        responseAudioMessage.text = "Audio Message"
        responseAudioMessage.textColor = isIncoming ? .lightGray : .lightText
        responseAudioMessage.font = UIFont(name: "Helvetica Neue", size: 15)
        let constraints = [
            responseNameLabel.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8),
            responseNameLabel.topAnchor.constraint(equalTo: responseLine.topAnchor, constant: 2),
            responseNameLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: 8),
            responseAudioMessage.topAnchor.constraint(equalTo: responseNameLabel.bottomAnchor, constant: -2),
            responseAudioMessage.leadingAnchor.constraint(equalTo: responseLine.leadingAnchor, constant: 8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func removeReplyOutlets() {
        replyMsgTopAnchor.isActive = false
        responseLine.removeFromSuperview()
        responseNameLabel.removeFromSuperview()
        responseAudioMessage.removeFromSuperview()
        responseTextMessage.removeFromSuperview()
        responseMediaMessage.removeFromSuperview()
        responseView.removeFromSuperview()
        msgTopAnchor.isActive = true
    }
    
    // MARK: - setup Audio Play Button
    
    private func setupAudioPlayButton() {
        audioPlayButton.isEnabled = false
        messageBackground.addSubview(audioPlayButton)
        audioPlayButton.addTarget(self, action: #selector(playAudioButtonPressed), for: .touchUpInside)
        audioPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        audioPlayButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            audioPlayButton.leadingAnchor.constraint(equalTo: messageBackground.leadingAnchor, constant: 8),
            audioPlayButton.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 8),
            audioPlayButton.heightAnchor.constraint(equalToConstant: 25),
            audioPlayButton.widthAnchor.constraint(equalToConstant: 25)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupAudioDurationLabel() {
        messageBackground.addSubview(durationLabel)
        durationLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            durationLabel.trailingAnchor.constraint(equalTo: messageBackground.trailingAnchor, constant: -8),
            durationLabel.centerYAnchor.constraint(equalTo: messageBackground.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: -
    
    @objc private func playAudioButtonPressed() {
        chatVC.handleUserPressedAudioButton(for: self)
    }
    
    // MARK: - timerHandler
    
    @objc func timerHandler() {
        if !audioPlayer.isPlaying {
            audioPlayButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            timer.invalidate()
            chatVC.chatAudio.audioPlayer = nil
        }
        let (minute, second) = timeFrom(seconds: Int(audioPlayer.duration - audioPlayer.currentTime))
        let minutes = minute < 10 ? "0\(minute)" : "\(minute)"
        let seconds = second < 10 ? "0\(second)" : "\(second)"
        durationLabel.text = "\(minutes):\(seconds)"
    }
    
    // MARK: -
    
    private func timeFrom(seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
