//
//  PostManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/7.
//
//  For uploading & downloading of posts

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

final class PostManager {
    
    static let shared: PostManager = PostManager()
    
    private init() {}
    
    // MARK: Firebase Reference
    
    let baseDbRef: DatabaseReference = Database.database().reference()
    
    let postDbRef: DatabaseReference = Database.database().reference().child("posts")
    
    // MARK: Firebase Storage Reference

    let photoStorageRef: StorageReference = Storage.storage().reference().child("photos")
    
    // MARK: - Upload Post
    
    func uploadPost(image: UIImage, caption: String, completion: @escaping () -> Void) {
        
        // Generate a unique ID for the post and prepare the post database reference
        let postDatabaseRef = postDbRef.childByAutoId()
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = postDatabaseRef.key else { return }

        let imageStorageRef = photoStorageRef.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 1024)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.7) else { return }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Observe the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
//            guard let username = Auth.auth().currentUser?.displayName else { return }
            let username = Auth.auth().currentUser?.displayName
            
            let userProfileImage = "https://firebasestorage.googleapis.com/v0/b/yogogo-ddcf9.appspot.com/o/photos%2F-MO-4gw5z5qCMbKHKzRl.jpg?alt=media&token=2330abe3-98bb-4a9d-b8e6-7929e58da0de"
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else { return }
                
                // Add a reference in the database
                let imageFileURL = url.absoluteString
                
                let userDidLike: [String] = ["me"]
                
                let caption = caption
                
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let post: [String: Any] = ["userId": userId,
                                            "username": username ?? "Unknown name",
                                            "userProfileImage": userProfileImage,
                                            "imageFileURL": imageFileURL,
                                            "userDidLike": userDidLike,
                                            "caption": caption,
                                            "timestamp": timestamp
                ]
                
                postDatabaseRef.setValue(post)
            })
            completion()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            
            print("Uploading... \(percentComplete)% complete")
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                print("Upload error -> ", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Download Post
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        var postQuery = postDbRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            
            // If the timestamp is specified, we will get the posts with timestamp newer than the given value
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        } else {
            
            // Otherwise, we will just get the most recent posts
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            
            print("👉 Total number of posts: \(snapshot.childrenCount)")
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("😭 There's no post.")
                return
            }
            
            for item in allObjects {
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            if newPosts.count > 0 {
                
                // Order in descending order (i.e. the latest post becomes the first post)
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            
            completionHandler(newPosts)
        })
        
    }
    
    func getOldPosts(start timestamp: Int, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        let postOrderedQuery = postDbRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("😭 There's no post.")
                return
            }
            
            for item in allObjects {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            // Order in descending order (i.e. the latest post becomes the first post)
            newPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completionHandler(newPosts)
        })
        
    }
}
