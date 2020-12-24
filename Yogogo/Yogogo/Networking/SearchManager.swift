//
//  SearchManager.swift
//  Insdogram
//
//  Created by prince on 2020/12/24.
//

import Firebase

class SearchManager {
    
    static let shared = SearchManager()
    
    private init() {}
    
    var users: [User] = []
    
    let ref = Database.database().reference()
    
    // MARK: - observe Users to get userIds
    
    func getUserIds(completion: @escaping ([String]) -> Void) {
        
        print("------ observe Users to get userIds... ------")
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let users = snapshot.value as? [String: Any] else { return }
            
            var userIds: [String] = []
            
            for userId in users.keys {
                userIds.append(userId)
                print("------ userId: \(userId) ------")
            }
            
            completion(userIds)
        }
    }
    
    // MARK: -
    
    func getUserInfo(of userId: String) {
        
        // Call Firebase API to retrieve the user info
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("------ User not found: \(userId) ------")
                return
            }
            
            self.users.append(user)
            self.users.removeDuplicates()
        }
    }
}
