//
//  PostModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Firebase

struct Post {
    
    // MARK: - Properties
    
    var postId: String

    var userId: String // User.id
    
    var imageFileURL: String
    
    var userDidLike: [String] // [User.id]
    
    var caption: String
    
    var timestamp: Int
    
    // MARK: - Firebase Keys
    
    enum PostInfoKey {
        
        static let userId = "userId"
        
        static let imageFileURL = "imageFileURL"
        
        static let userDidLike = "userDidLike"
        
        static let caption = "caption"
        
        static let timestamp = "timestamp"
    }
    
    // MARK: - Initialization
    
    init(postId: String,
         userId: String,
         imageFileURL: String,
         userDidLike: [String],
         caption: String,
         timestamp: Int
    ) {
        self.postId = postId
        self.userId = userId
        self.imageFileURL = imageFileURL
        self.userDidLike = userDidLike
        self.caption = caption
        self.timestamp = timestamp
    }
    
    // for Dictionary object
    init?(postId: String,
          postInfo: [String: Any]
    ) {
        guard let userId = postInfo[PostInfoKey.userId] as? String,
              let imageFileURL = postInfo[PostInfoKey.imageFileURL] as? String,
              let userDidLike = postInfo[PostInfoKey.userDidLike] as? [String],
              let caption = postInfo[PostInfoKey.caption] as? String,
              let timestamp = postInfo[PostInfoKey.timestamp] as? Int
        else { return nil }
        
        self = Post(postId: postId,
                    userId: userId,
                    imageFileURL: imageFileURL,
                    userDidLike: userDidLike,
                    caption: caption,
                    timestamp: timestamp
        )
    }
}
