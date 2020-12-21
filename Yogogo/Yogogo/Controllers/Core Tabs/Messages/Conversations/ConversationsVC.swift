//
//  ConversationsVC.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import UIKit
import Lottie
import Firebase

protocol NewConversationSelected {
    
    func showSelectedUser(selectedFriend: User)
}

class ConversationsVC: UIViewController {

    // ConversationVC is responsible for showing recent messages from user's friends and their actions. (If user and his/her friend haven't had a conversation, then friend's cell in tableView won't be visible. )
    
    let convNetworking = ConversationsNetworking()
    
    var messages = [Messages]()
    
    let tableView = UITableView()
    
    let calendar = Calendar(identifier: .gregorian)
    
    var newConversationButton = UIBarButtonItem()
    
    var tabBarBadge: UITabBarItem!
    
    let blankLoadingView = AnimationView(animation: Animation.named("blankLoadingAnim"))
    
//    var emptyListView: EmptyListView!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Messages"
        view.backgroundColor = .systemBackground
        if let tabItems = tabBarController?.tabBar.items {
            tabBarBadge = tabItems[3]
        }
        loadConversations()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: -
    
    private func setupUI() {
        setupNewConversationButton()
        setupTableView()
//        emptyListView = EmptyListView(nil, self, false)
        setupBlankView(blankLoadingView)
        Users.convVC = self
    }
    
    // MARK: -
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(ConversationsCell.self, forCellReuseIdentifier: "ConversationsCell")
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupNewConversationButton() {
        newConversationButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(newConversationTapped))
        newConversationButton.tintColor = .label
        navigationItem.rightBarButtonItem = newConversationButton
    }
    
    // MARK: -
    
    @objc func newConversationTapped() {
        let controller = NewConversationVC()
        controller.conversationDelegate = self
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    
    // MARK: -
    // MARK: LOAD CONVERSATIONS METHOD
    
    private func loadConversations() {
        convNetworking.convVC = self
        convNetworking.observeFriendsList()
    }
    
    // MARK: -
    
    func loadMessagesHandler(_ newMessages: [Messages]?) {
        blankLoadingView.isHidden = true
        if let newMessages = newMessages {
            handleReload(newMessages)
        }
        observeMessageActions()
    }
    
    // MARK: -
    // MARK: HANDLE RELOAD
    
    private func handleReload(_ newMessages: [Messages]) {
        messages = newMessages
        if messages.count != 0 {
//            emptyListView.isHidden = true
//            emptyListView.emptyButton.isHidden = true
        }
        messages.sort { (message1, message2) -> Bool in
            return message1.time.intValue > message2.time.intValue
        }
        tableView.reloadData()
    }
    
    // MARK: -
    // MARK: MESSAGE ACTIONS.
    
    func observeMessageActions() {
        convNetworking.observeDeletedMessages()
        convNetworking.observeNewMessages { (newMessages) in
            self.handleReload(newMessages)
        }
    }
    
    // MARK: -
    
    func nextControllerHandler(user: User) {
        let controller = ChatVC()
        controller.modalPresentationStyle = .fullScreen
        controller.user = user
        convNetworking.removeConvObservers()
        show(controller, sender: nil)
    }
    
    // MARK: -
    
    func observeIsUserTypingHandler(_ recent: Messages, _ cell: ConversationsCell) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        convNetworking.observeIsUserTyping(recent.determineUser()) { (isTyping, friendId) in
            if isTyping && cell.message?.determineUser() == friendId {
                cell.recentMessage.isHidden = true
                cell.timeLabel.isHidden = true
                cell.isTypingView.isHidden = false
                cell.checkmark.isHidden = true
            } else {
                self.setupNoTypingCell(cell)
                if cell.message?.sender == userId {
                    cell.checkmark.isHidden = false
                }
            }
        }
    }
    
    // MARK: -
    
    func observeIsUserSeenMessage(_ recent: Messages, _ cell: ConversationsCell) {
        guard let id = cell.message?.determineUser() else { return }
        convNetworking.observeUserSeenMessage(id) { (num) in
            if num == 0 {
                cell.checkmark.image = UIImage(named: "doubleCheckmark_icon")
            } else {
                cell.checkmark.image = UIImage(named: "checkmark_icon")
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ConversationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func setupNoTypingCell(_ cell: ConversationsCell) {
        cell.isTypingView.isHidden = true
        cell.recentMessage.isHidden = false
        cell.timeLabel.isHidden = false
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsCell") as? ConversationsCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let recent = messages[indexPath.row]
        cell.convVC = self
        cell.message = recent
        cell.unreadMessageView.isHidden = true
        convNetworking.observeUnreadMessages(recent.determineUser()) { (unreadMessage) in
            if let numOfMessages = unreadMessage[cell.message!.determineUser()], numOfMessages > 0 {
                cell.unreadMessageView.isHidden = false
                cell.unreadLabel.text = "\(numOfMessages)"
            } else {
                cell.unreadMessageView.isHidden = true
            }
        }
        return cell
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = messages[indexPath.row]
        for user in Users.list {
            if user.userId == chat.determineUser() {
                nextControllerHandler(user: user)
                break
            }
        }
    }
}

// MARK: -

extension ConversationsVC: NewConversationSelected {
    
    func showSelectedUser(selectedFriend: User) {
        nextControllerHandler(user: selectedFriend)
    }
}
