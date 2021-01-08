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
    
    let ref = Database.database().reference()
    
    // MARK: - Upload comment
    
    func uploadComment(post: Post, content: String, completion: @escaping () -> Void) {

        // Save to post.comments
        let commentRef = ref.child("comments").childByAutoId()
        guard let commentId = commentRef.key else { return }
        postManager.updatePostComments(post: post, commentId: commentId)
        
        // Encode the comment info
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let postId = post.postId
        let userDidLike: [String] = [""]
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        
        let comment: [String: Any] = [
            "postId": postId,
            "userId": userId,
            "content": content,
            "userDidLike": userDidLike,
            "timestamp": timestamp
        ]
        
        // Save to /comments/commentId
        commentRef.setValue(comment)
        completion()
    }
    
    // MARK: - Observe post comments for content & userDidLike
    
    func getComments(commentId: String, completion: @escaping (Comment) -> Void) {
        
        ref.child("comments").child(commentId).observeSingleEvent(of: .value) { (snapshot) in
            
            let commentInfo = snapshot.value as? [String: Any] ?? [:]
            guard let newComment = Comment(commentId: snapshot.key, commentInfo: commentInfo) else {
                print("------ Comment not found: \(snapshot.key) ------")
                return
            }

            print("------ newComment: \(newComment.commentId) ------")
            completion(newComment)
        }
    }
    
    // MARK: - Delete the comment
    
    func deleteComment(of post: Post, commentId: String) {
        
        // Update /posts/postId/comments on firebase
        let commentsToUpdate = post.comments.filter { $0 != commentId }
        ref.child("posts").child(post.postId).child("comments").setValue(commentsToUpdate)
        
        // Delete /comments/commentId on firebase
        ref.child("comments").child(commentId).removeValue()
    }
    
    // MARK: - Handle comment's userDidLike
    
    func updateUserDidLike(comment: Comment) {

        guard let userId = Auth.auth().currentUser?.uid else { return }
        var userDidLike = comment.userDidLike
        
        if userDidLike.contains(userId) {
            let filtered = userDidLike.filter { $0 != userId }
            ref.child("comments").child(comment.commentId).child("userDidLike").setValue(filtered)
            print("------ Dislike💔 ------")
            
        } else {
            userDidLike.append(userId)
            ref.child("comments").child(comment.commentId).child("userDidLike").setValue(userDidLike)
            print("------ Like❤️ ------")
        }
    }
}
