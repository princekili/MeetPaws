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
    
//    func fetchUsers(completion: @escaping (_ userList: [String: User]) -> Void) {
//
//        Firestore.firestore()
//            .collection("users")
//            .getDocuments { (querySnapshot, error) in
//
//                if let error = error {
//                    print("Error getting documents: \(error.localizedDescription)")
//
//                } else {
//                    guard let querySnapshot = querySnapshot else { return }
//
//                    for document in querySnapshot.documents {
//
//                        var user = User()
//
//                        let data: [String: Any] = document.data()
//
//                        user.profileImage = data["profileImage"] as? String
//                        user.username = data["name"] as? String
//                        user.userId = document.documentID
//                        print("\(String(describing: user.userId)) -> \(data)")
//
//                        if user.userId != CurrentUser.uid && user.userCheck() {
//                            self.usersList[user.userId!] = user
//                        }
//                    }
//                    return completion(self.usersList)
//                }
//        }
//    }
}
