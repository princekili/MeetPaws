//
//  CommentModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct Comment {
    
    var id: String
    
    var postId: String
    
    var authorId: String // User.id
    
    var username: String // User.username
    
    var profileImage: String // User.profileImage
    
    var userDidLike: [String] // [User.id]
    
    var text: String
    
    var timestamp: Timestamp
}
