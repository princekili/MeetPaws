//
//  NewConversationVC.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import UIKit
import Kingfisher

class NewConversationVC: UIViewController {

    let tableView = UITableView()
    
    weak var forwardDelegate: ChatVC!
    
    weak var conversationDelegate: ConversationsVC!
    
    var forwardName: String?
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForwardView()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .black
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: -
    
    private func setupForwardView() {
        navigationItem.title = forwardName != nil ? "Forward" : "New Conversation"
        let leftButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    // MARK: -
    
    @objc private func cancelButtonPressed() {
        forwardDelegate?.userResponse.messageToForward = nil
        forwardDelegate?.userResponse.messageSender = nil
        dismiss(animated: true, completion: nil)
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
        tableView.register(NewConversationCell.self, forCellReuseIdentifier: "NewConversationCell")
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
}

extension NewConversationVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Users.list.count
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationCell") as? NewConversationCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let user = Users.list[indexPath.row]
        
        let url = URL(string: user.profileImage)
        cell.profileImage.kf.setImage(with: url)
        cell.userFullName.text = user.fullName
        cell.username.text = user.username
        return cell
    }
    
    // MARK: -
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = Users.list[indexPath.row]
        if let name = forwardName {
            forwardDelegate?.forwardToSelectedFriend(user: user, for: name)
            dismiss(animated: true, completion: nil)
            return
        }
        conversationDelegate.showSelectedUser(selectedFriend: user)
        dismiss(animated: true, completion: nil)
    }
}
