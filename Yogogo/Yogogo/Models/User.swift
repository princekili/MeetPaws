//
//  FriendInfo.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct User {
    
    var userId: String

    var username: String
    
    var profileImage: String
    
    var fullName: String
    
    var bio: String
    
    var posts: [String] // postId
    
    var followRequests: [String] // userId
    
    var followers: [String] // userId
    
    var following: [String] // userId
    
    var postDidLike: [String] // postId
    
    var bookmarks: [String] // postId
    
    var ignoreList: [String]
    
    var joinedDate: Int // Timestamp yyyy-MM-dd
    
    var lastLogin: Int // Timestamp yyyy-MM-dd HH:MM:SS
    
    var isPrivate: Bool
    
    var isOnline: Bool
    
    var isMapLocationEnabled: Bool
    
    // MARK: - Firebase Keys
    
    enum UserInfoKey {
        
        static let username = "username"
        
        static let profileImage = "profileImage"
        
        static let fullName = "fullName"
        
        static let bio = "bio"
        
        static let posts = "posts"
        
        static let followRequests = "followRequests"
        
        static let followers = "followers"
        
        static let following = "following"
        
        static let postDidLike = "postDidLike"
        
        static let bookmarks = "bookmarks"
        
        static let ignoreList = "ignoreList"
        
        static let joinedDate = "joinedDate"
        
        static let lastLogin = "lastLogin"
        
        static let isPrivate = "isPrivate"
        
        static let isOnline = "isOnline"
        
        static let isMapLocationEnabled = "isMapLocationEnabled"
    }
    
    // MARK: - Initialization
    
    init(userId: String,
         username: String,
         profileImage: String,
         fullName: String,
         bio: String,
         posts: [String],
         followRequests: [String],
         followers: [String],
         following: [String],
         postDidLike: [String],
         bookmarks: [String],
         ignoreList: [String],
         joinedDate: Int,
         lastLogin: Int,
         isPrivate: Bool,
         isOnline: Bool,
         isMapLocationEnabled: Bool
    ) {
        self.userId = userId
        self.username = username
        self.profileImage = profileImage
        self.fullName = fullName
        self.bio = bio
        self.posts = posts
        self.followRequests = followRequests
        self.followers = followers
        self.following = following
        self.postDidLike = postDidLike
        self.bookmarks = bookmarks
        self.ignoreList = ignoreList
        self.joinedDate = joinedDate
        self.lastLogin = lastLogin
        self.isPrivate = isPrivate
        self.isOnline = isOnline
        self.isMapLocationEnabled = isMapLocationEnabled
    }
    
    // for Dictionary object
    init?(userId: String,
          userInfo: [String: Any]
    ) {
        guard let username = userInfo[UserInfoKey.username] as? String,
              let profileImage = userInfo[UserInfoKey.profileImage] as? String,
              let fullName = userInfo[UserInfoKey.fullName] as? String,
              let bio = userInfo[UserInfoKey.bio] as? String,
              let posts = userInfo[UserInfoKey.posts] as? [String],
              let followRequests = userInfo[UserInfoKey.followRequests] as? [String],
              let followers = userInfo[UserInfoKey.followers] as? [String],
              let following = userInfo[UserInfoKey.following] as? [String],
              let postDidLike = userInfo[UserInfoKey.postDidLike] as? [String],
              let bookmarks = userInfo[UserInfoKey.bookmarks] as? [String],
              let ignoreList = userInfo[UserInfoKey.ignoreList] as? [String],
              let joinedDate = userInfo[UserInfoKey.joinedDate] as? Int,
              let lastLogin = userInfo[UserInfoKey.lastLogin] as? Int,
              let isPrivate = userInfo[UserInfoKey.isPrivate] as? Bool,
              let isOnline = userInfo[UserInfoKey.isOnline] as? Bool,
              let isMapLocationEnabled = userInfo[UserInfoKey.isMapLocationEnabled] as? Bool
        
        else { return nil }
        
        self = User(userId: userId,
                    username: username,
                    profileImage: profileImage,
                    fullName: fullName,
                    bio: bio,
                    posts: posts,
                    followRequests: followRequests,
                    followers: followers,
                    following: following,
                    postDidLike: postDidLike,
                    bookmarks: bookmarks,
                    ignoreList: ignoreList,
                    joinedDate: joinedDate,
                    lastLogin: lastLogin,
                    isPrivate: isPrivate,
                    isOnline: isOnline,
                    isMapLocationEnabled: isMapLocationEnabled
        )
    }
}
