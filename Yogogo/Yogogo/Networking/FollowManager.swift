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
    
    var users: [User] = []
    
    let ref = Database.database().reference()
    
    let group = DispatchGroup()
    
    // MARK: - Get follower info
    
    private func getUserInfo(of userId: String) {
        
        // Call Firebase API to retrieve the user info
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
    
    // MARK: -
    
    func getUsers(userIds: [String], completion: @escaping () -> Void) {
        
        for userId in userIds {
            group.enter()
            getUserInfo(of: userId)
        }
        
        group.notify(queue: .main, execute: completion)
    }
}
