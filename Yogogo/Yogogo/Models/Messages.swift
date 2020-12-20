//
//  Messages.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import Foundation
import Firebase

class Messages {
    
    var message: String!
    
    var sender: String!
    
    var recipient: String!
    
    var time: NSNumber!
    
    var mediaUrl: String!
    
    var audioUrl: String!
    
    var videoUrl: String!
    
    var storageID: String!
    
    var imageWidth: NSNumber!
    
    var imageHeight: NSNumber!
    
    var id: String!
    
    var repMessage: String!
    
    var repMediaMessage: String!
    
    var repMID: String!
    
    var repSender: String!
    
    // MARK: -
    
    func determineUser() -> String {
        
        guard let uid = Auth.auth().currentUser?.uid else { return "" }
        
        if sender == uid {
            return recipient
            
        } else {
            return sender
        }
    }
}
