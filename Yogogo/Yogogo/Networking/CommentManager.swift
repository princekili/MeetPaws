//
//  CommentManager.swift
//  Insdogram
//
//  Created by prince on 2020/12/25.
//

import Foundation
import Firebase
import FirebaseDatabase

final class CommentManager {
    
    static let shared = CommentManager()
    
    private init() {}
    
    let userManager = UserManager.shared
    
    let postManager = PostManager.shared
    
    let commentRef = Database.database().reference().child("comments")
    
    // MARK: - Upload comment
    
    func uploadComment(content: String, completion: @escaping () -> Void) {
        
//        let commentDatabaseRef = commentRef.childByAutoId()
    }
}
