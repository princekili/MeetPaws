//
//  PostModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct Post {
    
    var id: String
    
    var authorId: String // User.id
    
    var authorProfileImage: String // User.profileImage
    
    var thumbnailImage: String // URL
    
    var images: [String] // [URL]
    
    var userDidLike: [String] // [User.id]
    
    var caption: String
    
    var timestamp: Timestamp
}
