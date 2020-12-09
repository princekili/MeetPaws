//
//  DatabaseManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import Foundation
import FirebaseDatabase

class DatabaseManager {
    
    static let shared: DatabaseManager = DatabaseManager()
    
    private init() {}
    
    // MARK: Firebase Reference
    
    let baseDbRef = Database.database().reference()
    
    let usersDbRef = Database.database().reference().child("users")
    
    // MARK: - Check Username
    
    func checkUsername(_ username: String, completion: @escaping (String) -> Void) {
        
        let usernameQuery = usersDbRef.queryOrdered(byChild: "username")
    }
}
