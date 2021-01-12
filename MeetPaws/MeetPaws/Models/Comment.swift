//
//  CommentModel.swift
//  MeetPaws
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct Comment: Hashable {
    
    var commentId: String
    
    var postId: String
    
    var userId: String // User.id
    
    var content: String
    
    var userDidLike: [String] // [User.id]
    
    var timestamp: Int
    
    // MARK: - Firebase Keys
    
    enum CommentInfoKey {
        
        static let postId = "postId"
        
        static let userId = "userId"
        
        static let content = "content"
        
        static let userDidLike = "userDidLike"
        
        static let timestamp = "timestamp"
    }
    
    // MARK: - Initialization
    
    init(commentId: String,
         postId: String,
         userId: String,
         content: String,
         userDidLike: [String],
         timestamp: Int
    ) {
        self.commentId = commentId
        self.postId = postId
        self.userId = userId
        self.content = content
        self.userDidLike = userDidLike
        self.timestamp = timestamp
    }
    
    // for Dictionary object
    init?(commentId: String,
          commentInfo: [String: Any]
    ) {
        guard let postId = commentInfo[CommentInfoKey.postId] as? String,
              let userId = commentInfo[CommentInfoKey.userId] as? String,
              let content = commentInfo[CommentInfoKey.content] as? String,
              let userDidLike = commentInfo[CommentInfoKey.userDidLike] as? [String],
              let timestamp = commentInfo[CommentInfoKey.timestamp] as? Int
        else { return nil }
        
        self = Comment(commentId: commentId,
                       postId: postId,
                       userId: userId,
                       content: content,
                       userDidLike: userDidLike,
                       timestamp: timestamp
        )
    }
}
