//
//  ConversationsNetworking.swift
//  MeetPaws
//
//  Created by prince on 2020/12/21.
//

import Firebase

class ConversationsNetworking {
    
    // MARK: -
    
    var convVC: ConversationsViewController!
    
    var groupedMessages = [String: Messages]()
    
    var unreadMessages = [String: Int]()
    
    var userKeys = [String]()
    
    var totalUnread = Int()
    
    let ref = Database.database().reference()
    
    // MARK: - To Fix !!!
    
    func messagesReference() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let users = SearchManager.shared.users
        
        for user in users {
            
            ref.child("messages").child(userId).child(user.userId).queryLimited(toLast: 1).observe(.value) { (snap) in
                    
                guard snap.childrenCount > 0 else {
                    self.convVC.loadMessagesHandler(nil)
                    return
                }
                    
                for child in snap.children {
                    guard let snapshot = child as? DataSnapshot else { return }
                    guard let values = snapshot.value as? [String: Any] else { return }
                    let message = MessageManager.setupUserMessage(for: values)
                    self.groupedMessages[message.determineUser()] = message
                }
                
                if user.userId == users[users.count - 1].userId {
                    self.convVC.loadMessagesHandler(Array(self.groupedMessages.values))
                }
            }
        }
    }
    
    // MARK: -
    
    func observeNewMessages(completion: @escaping (_ newMessages: [Messages]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for key in userKeys {
            ref.child("messages").child(userId).child(key).queryLimited(toLast: 1).observe(.childAdded) { (snap) in
                    
                guard let values = snap.value as? [String: Any] else { return }
                let message = MessageManager.setupUserMessage(for: values)
                let status = self.convVC.messages.contains { (oldMessage) -> Bool in
                    return message.id == oldMessage.id
                }
                if status {
                    return
                } else {
                    self.groupedMessages[message.determineUser()] = message
                    return completion(Array(self.groupedMessages.values))
                }
            }
        }
    }
    
    // MARK: -
    
    func observeDeletedMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for key in userKeys {
            
            ref.child("messages").child(userId).child(key).queryLimited(toLast: 1).observe(.childRemoved) { (snap) in
                    
                guard let values = snap.value as? [String: Any] else { return }
                let message = MessageManager.setupUserMessage(for: values)
                self.groupedMessages.removeValue(forKey: message.determineUser())
                self.convVC.messages = Array(self.groupedMessages.values)
                self.convVC.tableView.reloadData()
            }
        }
    }
    
    // MARK: -
    
    func observeUserSeenMessage(_ userId: String, completion: @escaping(_ userSeenMessagesCount: Int) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("messages").child("unread-Messages").child(userId).child(userId)
            .observe(.value) { (snap) in
            
                return completion(Int(snap.childrenCount))
        }
    }
    
    // MARK: -
    
    func observeIsUserTyping(_ userId: String, completion: @escaping (_ isTyping: Bool, _ userId: String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("userActions").child(userId).child(userId)
            .observe(.value) { (snap) in
                
            guard let data = snap.value as? [String: Any] else { return }
            guard let isTyping = data["isTyping"] as? Bool else { return }
            guard let userId = data["fromFriend"] as? String else { return }
            return completion(isTyping, userId)
        }
    }
    
    // MARK: -
    
    func removeConvObservers() {
        for message in convVC.messages {
            ref.child("users").child(message.determineUser()).removeAllObservers()
        }
    }
    
    // MARK: -
    
    func observeUnreadMessages(_ key: String, completion: @escaping(_ unreadMessages: [String: Int]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("messages").child("unread-Messages").child(userId).child(key)
            .observe(.value) { (snap) in
                
            self.totalUnread = 0
            self.unreadMessages[key] = Int(snap.childrenCount)
            self.addValueToBadge()
            return completion(self.unreadMessages)
        }
        
        ref.child("messages").child("unread-Messages").child(userId).child(key)
            .observe(.childRemoved) { (snap) in
                
            self.removeValueFromBadge(key)
            self.unreadMessages.removeValue(forKey: key)
            return completion(self.unreadMessages)
        }
    }
    
    // MARK: -
    
    private func addValueToBadge() {
        for msg in self.unreadMessages.values {
            totalUnread += msg
        }
        if totalUnread != 0 {
            self.convVC.tabBarBadge.badgeValue = "\(totalUnread)"
        }
    }
    
    // MARK: -
    
    private func removeValueFromBadge(_ key: String) {
        self.totalUnread -= self.unreadMessages[key] ?? 0
        if totalUnread == 0 {
            self.convVC.tabBarBadge.badgeValue = nil
        }
    }
}
