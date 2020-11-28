//
//  CommentModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Foundation

struct Comment {
    
    var id: String?
    
    var author: User?
    
    var userDidLike: [User]?
    
    var textContent: String?
    
    var timestamp: TimeInterval?
}
