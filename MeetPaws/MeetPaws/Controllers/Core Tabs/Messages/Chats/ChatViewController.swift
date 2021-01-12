//
//  ChatVC.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit
import Firebase
import AVFoundation
import CoreServices
import Lottie

class ChatViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {

    var user: User!
    
    var messages = [Messages]()
    
    let chatNetworking = ChatNetworking()
    
    var userResponse = UserResponse()
    
    var containerHeight: CGFloat!
    
    var collectionView: MessageCollectionView!
    
    var messageContainer: MessageContainer!
    
    var refreshIndicator: MessageLoadingIndicator!
    
    let calendar = Calendar(identifier: .gregorian)
    
    let ref = Database.database().reference()
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupChat()
        notificationCenterHandler()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        chatNetworking.removeObserves()
        tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // If iPhone ≥ X, it will move inputTF up
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        var topConst: CGFloat!
        
        // For iPhone ≥ X
        if view.safeAreaInsets.bottom > 0 {
            containerHeight = 84
            topConst = 44
            
        // MARK: - To Fix
        // For iPhone ≤ 8
        } else {
            containerHeight = 45
            topConst = 8
        }
        
        // MARK: - Layers order
        messageContainer = MessageContainer(height: containerHeight, const: topConst, chatVC: self)
        collectionView = MessageCollectionView(collectionViewLayout: UICollectionViewFlowLayout.init(), chatVC: self)
        refreshIndicator = MessageLoadingIndicator(frame: view.frame, const: topConst, chatVC: self)
        hideKeyboardOnTap()
    }
    
    // MARK: -
    
    func setupChat() {
        chatNetworking.chatVC = self
        chatNetworking.user = user
        setupChatNavBar()
        fetchMessages()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: ProfileImageButton(chatVC: self, url: user.profileImage))
        observeUserTyping()
    }
    
    // MARK: -
    
    private func setupChatNavBar() {
        let loginDate = Date(timeIntervalSince1970: TimeInterval((user.lastLogin)))
        navigationController?.navigationBar.tintColor = .label
        
        var displayName = user.fullName
        if user.fullName.isEmpty || user.fullName == " " {
            displayName = user.username
        }
        
        if user.isOnline {
            navigationItem.setNavTitles(navTitle: displayName, navSubtitle: "Online")
        } else {
            navigationItem.setNavTitles(navTitle: displayName, navSubtitle: calendar.calculateLastLogin(loginDate as Date))
        }
    }

    // MARK: - CLIP IMAGE BUTTON PRESSED METHOD
    
    @objc func addImageButtonPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.systemRed, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: -
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chatNetworking.uploadImage(image: originalImage) { (storageRef, image, mediaName) in
                self.chatNetworking.downloadImage(storageRef, image, mediaName)
            }
            dismiss(animated: true, completion: nil)
        }
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            chatNetworking.uploadVideoFile(videoUrl)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - SEND BUTTON PRESSED METHOD
    
    @objc func sendButtonPressed() {
        setupTextMessage()
    }
    
    // MARK: - HIDE KEYBOARD ON TAP
    
    private func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tap)
        navigationController?.navigationBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    // MARK: -
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - SEND TEXT MESSAGE METHOD
    
    private func setupTextMessage() {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        let trimmedMessage = messageContainer.messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedMessage.count > 0 else { return }
        
        let senderRef = ref.child("messages").child(currentUser.userId).child(user.userId).childByAutoId()
        let friendRef = ref.child("messages").child(user.userId).child(currentUser.userId).child(senderRef.key!)
        
        guard let messageId = senderRef.key else { return }
        var values = ["message": trimmedMessage,
                      "sender": currentUser.userId,
                      "recipient": user.userId,
                      "time": Date().timeIntervalSince1970,
                      "messageId": messageId] as [String: Any]
        
        if userResponse.repliedMessage != nil || userResponse.messageToForward != nil {
            
            let repValues = userResponse.messageToForward != nil ? userResponse.messageToForward : userResponse.repliedMessage
            
            if repValues?.message != nil {
                values["repMessage"] = repValues?.message
            
            } else if repValues?.mediaUrl != nil {
                values["repMediaMessage"] = repValues?.mediaUrl
            }
            
            values["repMID"] = repValues?.id
            values["repSender"] = userResponse.messageSender
            
            exitResponseButtonPressed()
        }
        chatNetworking.sendMessageHandler(senderRef: senderRef, friendRef: friendRef, values: values) { (error) in
            self.handleMessageTextSent(error)
        }
    }
    
    // MARK: -
    
    private func handleMessageTextSent(_ error: Error?) {
        guard error == nil else {
            showAlert(title: "Error", message: error?.localizedDescription)
            return
        }
        messageContainer.messageTextView.text = ""
        messageContainer.messageTextView.subviews[2].isHidden = false
        self.scrollToTheBottom(animated: false)
        hideKeyboard()
        chatNetworking.disableIsTyping()
        messageContainer.messageTextView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = 32
                if sendingIsFinished(const: messageContainer.heightAnchr) { return }
            }
            view.layoutIfNeeded()
        }
    }
    
    // MARK: To fix
    // MARK: - FETCH MESSAGES METHOD
    
    func fetchMessages() {
        chatNetworking.loadMore = true
        chatNetworking.scrollToIndex = []
        chatNetworking.getMessages(view, messages) { (newMessages, order) in
            self.chatNetworking.lastMessageReached = newMessages.count == 0
            if self.chatNetworking.lastMessageReached {
                self.observeMessageActions()
                return
            }
            self.chatNetworking.scrollToIndex = newMessages
            self.refreshIndicator.startAnimating()
            if order {
                self.refreshIndicator.order = order
                self.messages.append(contentsOf: newMessages)
            } else {
                self.refreshIndicator.order = order
                self.messages.insert(contentsOf: newMessages, at: 0)
            }
            self.handleReload()
        }
    }
    
    // MARK: -
    
    private func observeMessageActions() {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        chatNetworking.observeUserMessageSeen()
        let msgRef = ref.child("messages").child(currentUser.userId).child(user.userId)
        msgRef.observe(.childRemoved) { (snap) in
            self.chatNetworking.deleteMessageHandler(self.messages, for: snap) { (index) in
                self.messages.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            }
        }
        msgRef.queryLimited(toLast: 1).observe(.childAdded) { (snap) in
            self.chatNetworking.newMessageRecievedHandler(self.messages, for: snap) { (newMessage) in
                self.messages.append(newMessage)
                self.collectionView.reloadData()
                if newMessage.determineUser() != currentUser.userId {
                    self.scrollToTheBottom(animated: true)
                }
            }
        }
    }
    
    // MARK: -
    
    private func handleReload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.refreshIndicator.order {
                self.scrollToTheBottom(animated: false)
            } else {
                let index = self.chatNetworking.scrollToIndex.count - 1
                self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .top, animated: false)
            }
            self.chatNetworking.loadMore = false
            self.refreshIndicator.stopAnimating()
        }
        observeMessageActions()
    }
    
    // MARK: - Show UserProfileVC
    // MARK: To fix
    
    @objc func profileImageTapped() {
        // Show the user profile
    }
    
    // MARK: -
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed()
        return true
    }
    
    // MARK: - ZOOM IMAGE METHOD
    
    func zoomImageHandler(image: UIImageView, message: Messages) {
        if !collectionView.isLongPress {
            view.endEditing(true)
            _ = SelectedImageView(image, message, self)
        }
    }
    
    // MARK: -
    
    func messageContainerHeightHandler(_ const: NSLayoutConstraint, _ estSize: CGSize) {
        if sendingIsFinished(const: const) { return }
        var height = estSize.height
        if userResponse.responseStatus { height = estSize.height + 50 }
        if height > 150 { return }
        if messageContainer.messageTextView.calculateLines() >= 2 {
            if containerHeight > 45 {
                const.constant = height + 35
            } else { const.constant = height + 15 }
        }
    }
    
    // MARK: -
    
    func messageHeightHandler(_ constraint: NSLayoutConstraint, _ estSize: CGSize) {
        let height: CGFloat = userResponse.responseStatus == true ? 100 : 150
        if estSize.height > height {
            messageContainer.messageTextView.isScrollEnabled = true
            return
        } else if messageContainer.messageTextView.calculateLines() < 2 {
            constraint.constant = 32
            self.view.layoutIfNeeded()
            return
        }
        constraint.constant = estSize.height
        self.view.layoutIfNeeded()
    }
    
    // MARK: -
    
    private func sendingIsFinished(const: NSLayoutConstraint) -> Bool {
        let height: CGFloat = userResponse.responseStatus == true ? containerHeight + 50 : containerHeight
        if messageContainer.messageTextView.text.count == 0 {
            messageContainer.messageTextView.isScrollEnabled = false
            const.constant = height
            return true
        } else {
            return false
        }
    }
    
    // MARK: - NOTIFICATION CENTER
    
    private func notificationCenterHandler() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: -
    
    @objc private func willResignActive(_ notification: Notification) {
        chatNetworking.disableIsTyping()
    }
    
    // MARK: - Move the messageContainer View When the Keyboard Appears/Hides
    
    @objc private func handleKeyboardWillShow(notification: NSNotification) {
        let kFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let kDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        guard let height = kFrame?.height, let duration = kDuration else { return }
        if containerHeight > 45 {
            messageContainer.bottomAnchr.constant = 13.2
            collectionView.contentOffset.y -= 13.2
        }
        messageContainer.bottomAnchr.constant -= height
        collectionView.contentOffset.y += height
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleKeyboardWillHide(notification: NSNotification) {
        let kFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let kDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        guard let height = kFrame?.height else { return }
        guard let duration = kDuration else { return }
        if containerHeight > 45 {
            collectionView.contentOffset.y += 13.2
        }
        collectionView.contentOffset.y -= height
        messageContainer.bottomAnchr.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: -
    
    func animateSendButton() {
        var buttonToAnimate = UIButton()
        if messageContainer.messageTextView.text.count >= 1 {
            messageContainer.micButton.alpha = 0
            if messageContainer.sendButton.alpha == 1 { return }
            messageContainer.sendButton.alpha = 1
            buttonToAnimate = messageContainer.sendButton
        } else if messageContainer.messageTextView.text.count == 0 {
            messageContainer.micButton.alpha = 1
            messageContainer.sendButton.alpha = 0
            buttonToAnimate = messageContainer.micButton
        }
        buttonToAnimate.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            buttonToAnimate.transform = .identity
        })
    }
    
    // MARK: - OBSERVE TYPING METHOD
    
    private func observeUserTyping() {
        chatNetworking.observeIsUserTyping { (userActivity) in
            if userActivity.userId == self.user.userId && userActivity.isTyping ?? false {
                self.navigationItem.setupTypingNavTitle(navTitle: self.user.fullName)
            } else {
                self.setupChatNavBar()
            }
        }
    }
    
    // MARK: -
    
    private func scrollToTheBottom(animated: Bool) {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    // MARK: - handle Long PressGesture
    
    @objc func handleLongPressGesture(longPress: UILongPressGestureRecognizer) {
        if longPress.state != UIGestureRecognizer.State.began { return }
        collectionView.isLongPress = true
        let point = longPress.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ChatCell else { return }
        let message = messages[indexPath.row]
        openToolsMenu(message, cell)
    }
    
    private func openToolsMenu(_ message: Messages, _ selectedCell: ChatCell) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        hideKeyboard()
        collectionView.isUserInteractionEnabled = false
        selectedCell.isHidden = true
        _ = ToolsMenu(message, selectedCell, self)
    }
    
    func forwardButtonPressed(_ message: Messages) {
        chatNetworking.getMessageSender(message: message) { (name) in
            self.userResponse.messageToForward = message
            let convController = NewConversationViewController()
            convController.forwardDelegate = self
            convController.forwardName = name
            let navController = UINavigationController(rootViewController: convController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func responseButtonPressed(_ message: Messages, forwardedName: String? = nil) {
        responseViewChangeAlpha(alpha: 0)
        messageContainer.micButton.alpha = 0
        messageContainer.sendButton.alpha = 1
        messageContainer.messageTextView.becomeFirstResponder()
        userResponse.responseStatus = true
        userResponse.repliedMessage = message
        messageContainer.heightAnchr.constant += 50
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
            self.responseMessageLine(message, forwardedName)
        }) { (true) in
            self.responseViewChangeAlpha(alpha: 1)
        }
    }
}
