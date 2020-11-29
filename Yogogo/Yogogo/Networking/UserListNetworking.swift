//
//  UserListNetworking.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Firebase

class UserListNetworking {
    
    var usersList = [String: User]()
    
    func fetchUsers(completion: @escaping (_ userList: [String: User]) -> Void) {
        
        Firestore.firestore()
            .collection("users")
            .getDocuments { (querySnapshot, error) in
            
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                
                } else {
                    guard let querySnapshot = querySnapshot else { return }
                    
                    for document in querySnapshot.documents {
                        
                        var user = User()
                        
                        let data: [String: Any] = document.data()
                        
                        user.accessToken = data["accessToken"] as? String
                        user.profileImage = data["profileImage"] as? String
                        user.name = data["name"] as? String
                        user.id = document.documentID
                        print("\(String(describing: user.id)) -> \(data)")
                        
                        if user.id != CurrentUser.uid && user.userCheck() {
                            self.usersList[user.id!] = user
                        }
                    }
                    return completion(self.usersList)
                }
        }
    }
}
