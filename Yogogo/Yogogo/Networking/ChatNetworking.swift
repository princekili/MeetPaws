//
//  ChatNetworking.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import Foundation
import Firebase
import AVFoundation

class ChatNetworking {
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    let audioCache = NSCache<NSString, NSData>()
    
    var user: User!
    
    var loadMore = false
    
    var lastMessageReached = false
    
    var messageStatus = "Sent"
    
    var scrollToIndex = [Messages]()
    
    var isUserTyping = false
    
    var chatVC: ChatVC!
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: GET MESSAGES METHOD
    
    func getMessages(_ v: UIView, _ m: [Messages], completion: @escaping(_ newMessages: [Messages], _ mOrder: Bool) -> Void){
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        var nodeRef: DatabaseQuery
        var messageOrder = true
        var newMessages = [Messages]()
        var messageCount: UInt = 20
        if v.frame.height > 1000 { messageCount = 40 }
        let firstMessage = m.first
        
        if firstMessage == nil{
            nodeRef = Database.database().reference().child("messages").child(currentUser.uid).child(user.userId).queryOrderedByKey().queryLimited(toLast: messageCount)
            messageOrder = true
        }else{
            let mId = firstMessage!.id
            nodeRef = Database.database().reference().child("messages").child(currentUser.uid).child(user.userId).queryOrderedByKey().queryEnding(atValue: mId).queryLimited(toLast: messageCount)
            messageOrder = false
        }
        nodeRef.observeSingleEvent(of: .value) { (snap) in
            for child in snap.children {
                guard let snapshot = child as? DataSnapshot else { return }
                if firstMessage?.id != snapshot.key {
                    guard let values = snapshot.value as? [String: Any] else { return }
                    newMessages.append(MessageManager.setupUserMessage(for: values))
                }
            }
            return completion(newMessages, messageOrder)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func deleteMessageHandler(_ messages: [Messages], for snap: DataSnapshot, completion: @escaping (_ index: Int) -> Void){
        var index = 0
        for message in messages {
            if message.id == snap.key {
                return completion(index)
            }
            index += 1
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func removeMessageHandler(messageToRemove: Messages, completion: @escaping () -> Void) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Database.database().reference().child("messages").child(currentUser.uid).child(user.userId).child(messageToRemove.id).removeValue { (error, ref) in
            Database.database().reference().child("messages").child(self.user.userId).child(currentUser.uid).child(messageToRemove.id).removeValue()
            Database.database().reference().child("messages").child("unread-Messages").child(self.user.userId).child(currentUser.uid).child(messageToRemove.id).removeValue()
            if messageToRemove.audioUrl != nil {
                Storage.storage().reference().child("message-Audio").child(messageToRemove.storageID).delete { (error) in
                    guard error == nil else { return }
                }
            }else if messageToRemove.mediaUrl != nil{
                Storage.storage().reference().child("message-img").child(messageToRemove.storageID).delete { (error) in
                    guard error == nil else { return }
                }
            }
            guard error == nil else { return }
            return completion()
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func newMessageRecievedHandler(_ messages: [Messages], for snap: DataSnapshot, completion: @escaping (_ message: Messages) -> Void){
        let status = messages.contains { (message) -> Bool in return message.id == snap.key }
        if !status {
            guard let values = snap.value as? [String: Any] else { return }
            let newMessage = MessageManager.setupUserMessage(for: values)
            return completion(newMessage)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func uploadImage(image: UIImage, completion: @escaping (_ storageRef: StorageReference, _ image: UIImage, _ name: String) -> Void){
        let mediaName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message-img").child(mediaName)
        if let jpegName = image.jpegData(compressionQuality: 0.1) {
            let uploadTask = storageRef.putData(jpegName, metadata: nil) { (metadata, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                return completion(storageRef, image, mediaName)
            }
            countTimeRemaining(uploadTask)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func downloadImage(_ ref: StorageReference, _ image: UIImage, _ userId: String) {
        ref.downloadURL { (url, error) in
            guard let url = url else { return }
            self.sendMediaMessage(url: url.absoluteString, image, userId)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: SEND MEDIA MESSAGE METHOD
    
    private func sendMediaMessage(url: String, _ image: UIImage, _ userId: String) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        messageStatus = "Sent"
        let senderRef = Database.database().reference().child("messages").child(currentUser.uid).child(user.userId ).childByAutoId()
        let friendRef = Database.database().reference().child("messages").child(user.userId ).child(currentUser.uid).child(senderRef.key!)
        guard let messageId = senderRef.key else { return }
        let values = ["sender": currentUser.uid, "time": Date().timeIntervalSince1970, "recipient": user.userId, "mediaUrl": url, "width": image.size.width, "height": image.size.height, "messageId": messageId, "storageID": userId] as [String: Any]
        senderRef.updateChildValues(values)
        friendRef.updateChildValues(values)
        let unreadRef = Database.database().reference().child("messages").child("unread-Messages").child(user.userId ).child(currentUser.uid).child(senderRef.key!)
        let unreadValues = [senderRef.key: 1]
        unreadRef.updateChildValues(unreadValues)
        updateNavBar(user.fullName)
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: SEND TEXT MESSAGE METHOD
    
    func sendMessageHandler(senderRef: DatabaseReference, friendRef: DatabaseReference, values: [String: Any], completion: @escaping (_ error: Error?) -> Void){
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        messageStatus = "Sent"
        senderRef.updateChildValues(values) { (error, ref) in
            if let error = error {
                completion(error)
            }
            friendRef.updateChildValues(values)
            let unreadRef = Database.database().reference().child("messages").child("unread-Messages").child(self.user.userId).child(currentUser.uid).child(senderRef.key!)
            let unreadValues = [senderRef.key: 1]
            unreadRef.updateChildValues(unreadValues)
            completion(nil)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: OBSERVE USER TYPING METHOD
    
    func observeIsUserTyping(completion: @escaping (_ friendActivity: UserActivity) -> Void) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        readMessagesHandler()
        let db = Database.database().reference().child("userActions").child(user.userId).child(currentUser.uid)
        db.observe(.value) { (snap) in
            guard let data = snap.value as? [String: Any] else { return }
            guard let status = data["isTyping"] as? Bool else { return }
            guard let userId = data["fromFriend"] as? String else { return }
            self.isUserTyping = status
            let userActivity = UserActivity(isTyping: status, userId: userId)
            return completion(userActivity)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func isTypingHandler(tV: UITextView) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let friendId = user?.userId else { return }
        
        let userRef = Database.database().reference().child("userActions").child(currentUser.uid).child(friendId)
        if tV.text.count >= 1 {
            userRef.setValue(["isTyping": true, "fromFriend": currentUser.uid])
        }else{
            userRef.setValue(["isTyping": false, "fromFriend": currentUser.uid])
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func disableIsTyping(){
        guard let friendId = user.userId , let user = currentUser.uid else { return }
        let userRef = Database.database().reference().child("userActions").child(currentUser.uid).child(friendId)
        userRef.updateChildValues(["isTyping": false, "fromFriend": user])
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func getMessageSender(message: Messages, completion: @escaping (_ sender: String) -> Void){
        Database.database().reference().child("messages").child(currentUser.uid).child(message.determineUser()).child(message.userId).observeSingleEvent(of: .value) { (snap) in
            guard let values = snap.value as? [String: Any] else { return }
            let senderId = values["sender"] as? String
            guard let sender = senderId == currentUser.uid ? currentUser.name : self.friend.name else { return }
            completion(sender)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func uploadAudio(file: Data){
        let audioName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message-Audio").child(audioName)
        let uploadTask = storageRef.putData(file, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.downloadAudioUrl(storageRef, audioName)
        })
        countTimeRemaining(uploadTask)
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func countTimeRemaining(_ uploadTask: StorageUploadTask) {
        uploadTask.observe(.progress) { (snap) in
            guard let progress = snap.progress else { return }
            let percentCompleted = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            var tempName = "Uploading File: \(round(100*percentCompleted)/100)% completed"
            if percentCompleted == 100.0 {
                tempName = "Almost done..."
            }
            self.updateNavBar(tempName)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func updateNavBar(_ tempName: String) {
        if tempName == user.fullName && isUserTyping {
            chatVC.navigationItem.setupTypingNavTitle(navTitle: user.fullName)
            return
        }
        let loginDate = NSDate(timeIntervalSince1970: (friend.lastLogin ?? 0).doubleValue)
        if user.isOnline {
            chatVC.navigationItem.setNavTitles(navTitle: tempName, navSubtitle: "Online")
        }else{
            chatVC.navigationItem.setNavTitles(navTitle: tempName, navSubtitle: chatVC.calendar.calculateLastLogin(loginDate))
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func downloadAudioUrl(_ ref: StorageReference, _ userId: String){
        ref.downloadURL { (url, error) in
            guard let url = url else { return }
            self.sendAudioMessage(with: url.absoluteString, and: userId)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: SEND AUDIO MESSAGE METHOD
    
    private func sendAudioMessage(with url: String, and userId: String) {
        messageStatus = "Sent"
        let senderRef = Database.database().reference().child("messages").child(currentUser.uid).child(friend.userId ).childByAutoId()
        let friendRef = Database.database().reference().child("messages").child(friend.userId ).child(currentUser.uid).child(senderRef.key!)
        guard let messageId = senderRef.key else { return }
        let values = ["sender": currentUser.uid!, "time": Date().timeIntervalSince1970, "recipient": friend.userId, "audioUrl": url,"messageId": messageId, "storageID": userId] as [String: Any]
        senderRef.updateChildValues(values)
        friendRef.updateChildValues(values)
        let unreadRef = Database.database().reference().child("messages").child("unread-Messages").child(self.friend.userId ).child(currentUser.uid).child(senderRef.key!)
        let unreadValues = [senderRef.key: 1]
        unreadRef.updateChildValues(unreadValues)
        updateNavBar(friend.name ?? "")
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func downloadMessageAudio(with url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void){
        if let cachedData = audioCache.object(forKey: url.absoluteString as NSString) {
            return completion(Data(referencing: cachedData), nil)
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return completion(nil, error)
            }
            DispatchQueue.main.async {
                self.audioCache.setObject(NSData(data: data), forKey: url.absoluteString as NSString)
                return completion(data, nil)
            }
        }
        task.resume()
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func uploadVideoFile(_ url: URL){
        do{
            let data = try Data(contentsOf: url)
            let uniqueName = NSUUID().uuidString + ".mov"
            let ref = Storage.storage().reference().child("message-Videos").child(uniqueName)
            let uploadTask = ref.putData(data, metadata: nil) { (metadata, error) in
                if error != nil{
                    self.chatVC.showAlert(title: "Error", message: error?.localizedDescription)
                    return
                }
                self.downloadVideoFile(url, ref, userId: uniqueName)
            }
            countTimeRemaining(uploadTask)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func downloadVideoFile(_ oldURL: URL, _ ref: StorageReference, userId: String) {
        ref.downloadURL { (url, error) in
            guard let url = url else { return }
            if let image = self.getFirstImageVideoFrame(for: oldURL) {
                self.handleDownloadVideoFile(image, url, userId)
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func handleDownloadVideoFile(_ image: UIImage, _ url: URL, _ userId: String) {
        self.uploadImage(image: image) { (storageRef, image, mediaName) in
            storageRef.downloadURL { (imageUrl, error) in
                guard let imageUrl = imageUrl else { return }
                self.handleSendVideoMessage(userId, url.absoluteString, image, imageUrl.absoluteString)
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    // MARK: SEND VIDEO MESSAGE METHOD
    
    private func handleSendVideoMessage(_ userId: String, _ url: String, _ image: UIImage, _ imageUrl: String) {
        messageStatus = "Sent"
        let senderRef = Database.database().reference().child("messages").child(currentUser.uid).child(friend.userId ).childByAutoId()
        let friendRef = Database.database().reference().child("messages").child(friend.userId ).child(currentUser.uid).child(senderRef.key!)
        guard let messageId = senderRef.key else { return }
        let values = ["sender": currentUser.uid!, "time": Date().timeIntervalSince1970, "recipient": friend.userId, "mediaUrl": imageUrl, "videoUrl": url,"messageId": messageId, "storageID": userId, "width": image.size.width, "height": image.size.height] as [String: Any]
        senderRef.updateChildValues(values)
        friendRef.updateChildValues(values)
        let unreadRef = Database.database().reference().child("messages").child("unread-Messages").child(self.friend.userId ).child(currentUser.uid).child(senderRef.key!)
        let unreadValues = [senderRef.key: 1]
        unreadRef.updateChildValues(unreadValues)
        updateNavBar(friend.name ?? "")
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func getFirstImageVideoFrame(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        do{
            let cgImage = try generator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: cgImage)
        }catch{
            print(error.localizedDescription)
        }
        return nil
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    private func readMessagesHandler(){
        let unreadRef = Database.database().reference().child("messages").child("unread-Messages").child(currentUser.uid).child(friend.userId )
        unreadRef.observe(.childAdded) { (snap) in
            unreadRef.removeValue()
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func removeObserves(){
        Database.database().reference().child("messages").child("unread-Messages").child(currentUser.uid).child(friend.userId ).removeAllObservers()
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
    func observeUserMessageSeen() {
        Database.database().reference().child("messages").child("unread-Messages").child(friend.userId ).child(currentUser.uid).observe(.value) { (snap) in
            if Int(snap.childrenCount) > 0{
                self.messageStatus = "Sent"
            }else{
                guard self.chatVC.messages.count != 0 else { return }
                self.messageStatus = "Seen"
                self.chatVC.collectionView.reloadData()
            }
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------------------- //
    
}
