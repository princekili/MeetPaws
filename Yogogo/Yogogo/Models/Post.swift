//
//  PostModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct Post {
    
    var id: String
    
    var authorID: String // User.id
    
    var authorProfileImage: String // User.profileImage
    
    var thumbnailImage: String
    
    var images: [String]
    
    var userDidLike: [String] // [User.id]
    
    var caption: String
    
    var timestamp: Timestamp
}
