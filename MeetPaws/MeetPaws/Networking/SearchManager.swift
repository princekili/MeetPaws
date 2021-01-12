//
//  SearchManager.swift
//  MeetPaws
//
//  Created by prince on 2020/12/24.
//

import Firebase

class SearchManager {
    
    static let shared = SearchManager()
    
    private init() {}
    
    var users: [User] = []
    
    let ref = Database.database().reference()
    
    // MARK: - 1. Get all userIds
    
    private func getUserIds(completion: @escaping ([String]) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let users = snapshot.value as? [String: Any] else { return }
            var userIds: [String] = []
            
            for userId in users.keys {
                // The userId should not be in the ignoreList
                if let ignoreList = UserManager.shared.currentUser?.ignoreList {
                    guard !ignoreList.contains(userId) else { continue }
                }
                userIds.append(userId)
            }
            completion(userIds)
        }
    }
    
    // MARK: - 2. Get userInfo
    
    private func getUserInfo(of userId: String) {
        
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
    
    // MARK: -
    
    func getUsers(completion: @escaping () -> Void) {
        
        getUserIds { [weak self] (userIds) in
            // Get all users' userInfo
            for userId in userIds {
                self?.getUserInfo(of: userId)
            }
        }
        completion()
    }
}
