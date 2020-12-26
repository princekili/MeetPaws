//
//  PostModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Foundation

struct Post: Hashable {
    
    // MARK: - Properties
    
    var postId: String

    var userId: String // User.id
    
    var imageFileURL: String
    
    var caption: String
    
    var userDidLike: [String] // [User.id]
    
    var comments: [String] // [Comment.commentId]
    
    var timestamp: Int
    
    // MARK: - Firebase Keys
    
    enum PostInfoKey {
        
        static let userId = "userId"
        
        static let imageFileURL = "imageFileURL"
        
        static let caption = "caption"
        
        static let userDidLike = "userDidLike"
        
        static let comments = "comments"
        
        static let timestamp = "timestamp"
    }
    
    // MARK: - Initialization
    
    init(postId: String,
         userId: String,
         imageFileURL: String,
         caption: String,
         userDidLike: [String],
         comments: [String],
         timestamp: Int
    ) {
        self.postId = postId
        self.userId = userId
        self.imageFileURL = imageFileURL
        self.caption = caption
        self.userDidLike = userDidLike
        self.comments = comments
        self.timestamp = timestamp
    }
    
    // for Dictionary object
    init?(postId: String,
          postInfo: [String: Any]
    ) {
        guard let userId = postInfo[PostInfoKey.userId] as? String,
              let imageFileURL = postInfo[PostInfoKey.imageFileURL] as? String,
              let caption = postInfo[PostInfoKey.caption] as? String,
              let userDidLike = postInfo[PostInfoKey.userDidLike] as? [String],
              let comments = postInfo[PostInfoKey.comments] as? [String],
              let timestamp = postInfo[PostInfoKey.timestamp] as? Int
        else { return nil }
        
        self = Post(postId: postId,
                    userId: userId,
                    imageFileURL: imageFileURL,
                    caption: caption,
                    userDidLike: userDidLike,
                    comments: comments,
                    timestamp: timestamp
        )
    }
}
