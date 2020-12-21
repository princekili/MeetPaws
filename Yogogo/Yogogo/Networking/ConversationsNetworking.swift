//
//  ConversationsNetworking.swift
//  Insdogram
//
//  Created by prince on 2020/12/21.
//

import Firebase

class ConversationsNetworking {
    
    // MARK: -
    
    var convVC: ConversationsVC!
    
    var groupedMessages = [String: Messages]()
    
    var unreadMessages = [String: Int]()
    
    var friendKeys = [String]()
    
    var totalUnread = Int()
    
    // MARK: -
    
   func observeFriendsList() {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    
        convVC.blankLoadingView.isHidden = false
        Database.database().reference().child("friendsList").child(userId).observeSingleEvent(of: .value) { (snap) in
            for child in snap.children {
                guard let snapshot = child as? DataSnapshot else { return }
                guard let friend = snapshot.value as? [String: Any] else { return }
                self.friendKeys.append(contentsOf: Array(friend.keys))
            }
            guard self.friendKeys.count > 0 else {
                self.convVC.loadMessagesHandler(nil)
                return
            }
            self.messagesReference()
        }
    }
    
    // MARK: -
    
    private func observeFriendActions() {
        observeRemovedFriends()
        observeNewFriends()
    }
    
    // MARK: -
    
    private func observeRemovedFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("friendsList").child(userId).observe(.childRemoved) { (snap) in
            let friendToRemove = snap.key
            var index = 0
            for message in self.convVC.messages {
                if message.determineUser() == friendToRemove {
                    self.groupedMessages.removeValue(forKey: friendToRemove)
                    self.convVC.messages.remove(at: index)
                    self.removeFriendFromArray(friendToRemove)
                    self.convVC.tableView.reloadData()
                    return
                }
                index += 1
            }
        }
    }
    
    // MARK: -
    
    private func observeNewFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("friendsList").child(userId).observe(.childAdded) { (snap) in
            let friendToAdd = snap.key
            let status = self.friendKeys.contains { (key) -> Bool in
                return key == friendToAdd
            }
            if status {
                return
            }else{
                self.friendKeys.append(friendToAdd)
                self.convVC.observeMessageActions()
            }
        }
    }
    
    // MARK: -
    
    private func removeFriendFromArray(_ friendToRemove: String) {
        var index = 0
        for friend in friendKeys {
            if friendToRemove == friend {
                friendKeys.remove(at: index)
            }
            index += 1
        }
    }
    
    // MARK: -
    
    private func messagesReference() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for key in friendKeys {
            Database.database().reference().child("messages").child(userId).child(key).queryLimited(toLast: 1).observeSingleEvent(of: .value) { (snap) in
                guard snap.childrenCount > 0 else {
                    self.convVC.loadMessagesHandler(nil)
                    return
                }
                for child in snap.children {
                    guard let snapshot = child as? DataSnapshot else { return }
                    guard let values = snapshot.value as? [String : Any] else { return }
                    let message = MessageManager.setupUserMessage(for: values)
                    self.groupedMessages[message.determineUser()] = message
                }
                if key == self.friendKeys[self.friendKeys.count - 1] {
                    self.convVC.loadMessagesHandler(Array(self.groupedMessages.values))
                }
            }
        }
    }
    
    // MARK: -
    
    func observeNewMessages(completion: @escaping (_ newMessages: [Messages]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for key in friendKeys {
            Database.database().reference().child("messages").child(userId).child(key).queryLimited(toLast: 1).observe(.childAdded) { (snap) in
                guard let values = snap.value as? [String: Any] else { return }
                let message = MessageManager.setupUserMessage(for: values)
                let status = self.convVC.messages.contains { (oldMessage) -> Bool in
                    return message.id == oldMessage.id
                }
                if status {
                    return
                }else{
                    self.groupedMessages[message.determineUser()] = message
                    return completion(Array(self.groupedMessages.values))
                }
            }
        }
        self.observeFriendActions()
    }
    
    // MARK: -
    
    func observeDeletedMessages() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for key in friendKeys {
            Database.database().reference().child("messages").child(userId).child(key).queryLimited(toLast: 1).observe(.childRemoved) { (snap) in
                guard let values = snap.value as? [String: Any] else { return }
                let message = MessageManager.setupUserMessage(for: values)
                self.groupedMessages.removeValue(forKey: message.determineUser())
                self.convVC.messages = Array(self.groupedMessages.values)
                self.convVC.tableView.reloadData()
            }
        }
    }
    
    // MARK: -
    
    private func loadFriends(_ recent: Messages, completion: @escaping (_ user: User) -> Void) {
        
        let user = recent.determineUser()
        let ref = Database.database().reference().child("users").child(user)
        ref.observe(.value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: snapshot.key, userInfo: userInfo) else {
                print("------ User not found ------")
                return
            }
            
            return completion(user)
            
//            guard let values = snap.value as? [String: Any] else { return }
//            var friend = User()
//            friend.id = snap.key
//            friend.name = values["name"] as? String
//            friend.email = values["email"] as? String
//            friend.isOnline = values["isOnline"] as? Bool
//            friend.lastLogin = values["lastLogin"] as? NSNumber
//            friend.profileImage = values["profileImage"] as? String
//            friend.isMapLocationEnabled = values["isMapLocationEnabled"] as? Bool
//            return completion(friend)
        }
    }
    
    // MARK: -
    
    func observeUserSeenMessage(_ friendId: String, completion: @escaping(_ userSeenMessagesCount: Int) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("messages").child("unread-Messages").child(friendId).child(userId)
        ref.observe(.value) { (snap) in
            return completion(Int(snap.childrenCount))
        }
    }
    
    // MARK: -
    
    func observeIsUserTyping(_ friendId: String, completion: @escaping (_ isTyping: Bool, _ friendId: String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("userActions").child(friendId).child(userId)
        ref.observe(.value) { (snap) in
            guard let data = snap.value as? [String: Any] else { return }
            guard let isTyping = data["isTyping"] as? Bool else { return }
            guard let friendId = data["fromFriend"] as? String else { return }
            return completion(isTyping, friendId)
        }
    }
    
    // MARK: -
    
    func removeConvObservers() {
        for message in convVC.messages {
            Database.database().reference().child("users").child(message.determineUser()).removeAllObservers()
        }
    }
    
    // MARK: -
    
    func observeUnreadMessages(_ key: String, completion: @escaping(_ unreadMessages: [String: Int]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("messages").child("unread-Messages").child(userId).child(key).observe(.value) { (snap) in
            self.totalUnread = 0
            self.unreadMessages[key] = Int(snap.childrenCount)
            self.addValueToBadge()
            return completion(self.unreadMessages)
        }
        Database.database().reference().child("messages").child("unread-Messages").child(userId).child(key).observe(.childRemoved) { (snap) in
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
