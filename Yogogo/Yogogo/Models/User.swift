//
//  FriendInfo.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Foundation

// MARK: - User Info Model

struct User {
    
    var id: String?
    
    var accessToken: String?
    
    var profileImage: String?
    
    var name: String?
    
    var bio: String?
    
    var posts: [Post]?
    
    var followRequests: [User]?
    
    var followers: [User]?
    
    var following: [User]?
    
    var postDidLike: [String]?
    
    var collections: [String]?
    
    var ignoreList: [String]?
    
    var registeredTime: TimeInterval?
    
    var isPrivate: Bool?
    
//    var userActivities: [Activity]
    
    var isOnline: Bool?
    
    var lastLogin: NSNumber?
    
    var isMapLocationEnabled: Bool?

    func userCheck() -> Bool {
        if id == nil || name == nil || profileImage == nil, accessToken == nil {
            return false
        }
        return true
    }
}

class Users {
    
    static var list = [User]()
    
//    static var conversationsVC: ConversationsVC?
    
    let userForTest = User(id: "J2jPvTNePXRWmngioPzA",
                           accessToken: "",
                           profileImage: "https://firebasestorage.googleapis.com/v0/b/mchat-764dc.appspot.com/o/ProfileImages%2F4C68F0A3-C6B7-43DB-96D2-391EB16D4953.jpg?alt=media&token=96ad3668-96d2-4739-90cd-4dd1e74060f2",
                           name: "Meitzu",
                           bio: nil,
                           posts: nil,
                           followRequests: nil,
                           followers: nil,
                           following: nil,
                           postDidLike: nil,
                           collections: nil,
                           ignoreList: nil,
                           registeredTime: nil,
                           isPrivate: nil,
                           isOnline: true,
                           lastLogin: 1606566756.480166,
                           isMapLocationEnabled: true)
}
