//
//  PostModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Foundation

struct Post {
    
    var id: String?
    
    var author: User?
    
    var images: [String]?
    
    var userDidLike: [User]?
    
    var textContent: String?
    
    var comments: [Comment]?
    
    var timestamp: TimeInterval?
}

