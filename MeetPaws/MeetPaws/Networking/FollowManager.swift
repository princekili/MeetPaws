//
//  FollowManager.swift
//  Insdogram
//
//  Created by prince on 2020/12/30.
//

import Firebase

class FollowManager {
    
    static let shared = FollowManager()
    
    private init() {}
    
    var users: [User] = [] // To store followers or following
    
    let ref = Database.database().reference()
    
    let group = DispatchGroup() // GCD
    
    // MARK: - Get follower info
    
    private func getUserInfo(of userId: String) {
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("------ Follower not found: \(userId) ------")
                return
            }
            
            self.users.append(user)
            self.group.leave()
            self.users.removeDuplicates()
        }
    }
    
    func getUsers(userIds: [String], completion: @escaping () -> Void) {
        
        for userId in userIds {
            // The userId should not be in the ignoreList
            if let ignoreList = UserManager.shared.currentUser?.ignoreList {
                guard !ignoreList.contains(userId) else { continue }
            }
            
            group.enter()
            getUserInfo(of: userId)
        }
        
        group.notify(queue: .main, execute: completion)
    }
    
    // MARK: - Observe the user
    
    func observeUser(of userId: String, completion: @escaping (User) -> Void) {
        
        ref.child("users").child(userId).observe(.value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            if let user = User(userId: userId, userInfo: userInfo) {
                completion(user)
            }
        }
    }
    
    // MARK: - Follow
    
    func follow(the user: User) {
        addFollowing(with: user)
        addFollower(with: user)
    }
    
    // Add the user.userId to the 'following' of the current user
    private func addFollowing(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var following = currentUser.following
        following.append(user.userId)
        following.removeDuplicates()
        
        ref.child("users").child(currentUser.userId).child("following").setValue(following)
    }
    
    // Add the userId of the current user to the 'follower' of the user
    private func addFollower(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var followers = user.followers
        followers.append(currentUser.userId)
        followers.removeDuplicates()
        
        ref.child("users").child(user.userId).child("followers").setValue(followers)
    }
    
    // MARK: - Unfollow
    
    func unfollow(the user: User) {
        removeFromMyFollowing(with: user)
        removeFromTheirFollower(with: user)
    }
    
    // Remove the user.userId from the 'following' of the current user
    private func removeFromMyFollowing(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var following = currentUser.following
        following = following.filter { $0 != user.userId }
        following.removeDuplicates()
        
        ref.child("users").child(currentUser.userId).child("following").setValue(following)
    }
    
    // Remove the userId of the current user from the 'follower' of the user
    private func removeFromTheirFollower(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var followers = user.followers
        followers = followers.filter { $0 != currentUser.userId}
        followers.removeDuplicates()
        
        ref.child("users").child(user.userId).child("followers").setValue(followers)
    }
    
    // MARK: - Remove the user from followers
    
    func remove(the user: User, completion: @escaping () -> Void) {
        removeFromTheirFollowing(with: user)
        removeFromMyFollower(with: user)
        completion()
    }
    
    // Remove the userId of the current user from the 'following' of the user
    private func removeFromTheirFollowing(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var following = user.following
        following = following.filter { $0 != currentUser.userId }
        following.removeDuplicates()
        
        ref.child("users").child(user.userId).child("following").setValue(following)
    }
    
    // Remove the user.userId from the 'follower' of the current user
    private func removeFromMyFollower(with user: User) {
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        var followers = currentUser.followers
        followers = followers.filter { $0 != user.userId }
        followers.removeDuplicates()
        
        ref.child("users").child(currentUser.userId).child("followers").setValue(followers)
    }
}
