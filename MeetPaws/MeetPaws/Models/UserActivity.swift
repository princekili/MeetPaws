//
//  UserIsTypingModel.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Foundation

struct UserActivity {
    
    let isTyping: Bool?
    
    let userId: String?
    
    init(isTyping: Bool, userId: String) {
        
        self.isTyping = isTyping
        
        self.userId = userId
    }
}
