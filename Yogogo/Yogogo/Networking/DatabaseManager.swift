//
//  DatabaseManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import Foundation
import FirebaseDatabase
import Firebase

class AuthManager {
    
    static let shared: AuthManager = AuthManager()
    
    private init() {}
    
    // MARK: Firebase Reference
    
    let ref = Database.database().reference()
    
    // MARK: - Check if first time sign in
    
    func checkFirstTimeSignIn(completion: @escaping (Bool?) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            var isFirstTime: Bool? = nil
            
            let uid = Auth.auth().currentUser?.uid
            
            guard let allUsers = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no user.")
                return
            }
            
            for user in allUsers {
//                let value = user.value as? [String: Any] ?? [:]
                if user.key == uid {
                    isFirstTime = false
                } else {
                    isFirstTime = true
                }
            }
            completion(isFirstTime)
        }
    }
    
    // MARK: - Get the user info
    
    func getUserInfo(userId: String, completion: @escaping (User) -> Void) {
        
        // Call Firebase API to retrieve the user info
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("User not found!")
                return
            }
            
            // Save user info to UserDefaults?
            
            completion(user)
        }
    }
    
    // MARK: - Check if the username exists
    
    func checkUsername(_ userId: String, completion: @escaping (Bool?) -> Void) {
        
        var hasUsername: Bool? = nil
            
        getUserInfo(userId: userId) { (user) in
            
            if user.username == "" {
                hasUsername = false
            } else {
                hasUsername = true
            }
        }
        completion(hasUsername)
    }
}
