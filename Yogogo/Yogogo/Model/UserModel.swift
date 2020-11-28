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
    
    var blacklistUser: [String]?
    
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
}
