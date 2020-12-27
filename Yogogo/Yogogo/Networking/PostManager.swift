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
    
    let userManager = UserManager.shared
    
    var postsOfCurrentUser: [Post]?
    
    let postsRef: DatabaseReference = Database.database().reference().child("posts")

    let photoStorageRef: StorageReference = Storage.storage().reference().child("photos")
    
    // MARK: - Upload Post
    
    func uploadPost(image: UIImage, caption: String, completion: @escaping () -> Void) {
        
        // Generate a unique ID for the post and prepare the post database reference
        let postDatabaseRef = postsRef.childByAutoId()
        
        // Save postId to UserManager
        guard let postId = postDatabaseRef.key else { return }
        userManager.currentUser?.posts.insert(postId, at: 0)
        
        userManager.updateUserPosts {
            print("------ New added postId: \(postId) ------")
        }
        
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
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else { return }
                
                // Add a reference in the database
                let imageFileURL = url.absoluteString
                let caption = caption
                let userDidLike: [String] = [""]
                let comments: [String] = [""]
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let post: [String: Any] = [
                    "userId": userId,
                    "imageFileURL": imageFileURL,
                    "caption": caption,
                    "userDidLike": userDidLike,
                    "comments": comments,
                    "timestamp": timestamp
                ]
                
                postDatabaseRef.setValue(post)
            })
            
            // Describe what to do at where uploadPost() is called.
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
    
    // MARK: - Download Posts for Feed
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completion: @escaping ([Post]) -> Void) {
        
        // Ordered by timestamp
        var postQuery = postsRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            
            // If the timestamp is specified, we will get the posts with timestamp newer than the given value
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1,
                                                childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        } else {
            
            // Otherwise(Default timestamp = nil), we will just get the most recent posts
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in

            
            var newPosts: [Post] = []
            
            print("------ Total number of new posts: \(snapshot.childrenCount) ------")
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no post.")
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
            
            completion(newPosts)
        })
        
    }
    
    func getOldPosts(start timestamp: Int, limit: UInt, completion: @escaping ([Post]) -> Void) {
        
        let postOrderedQuery = postsRef.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1,
                                                            childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var oldPosts: [Post] = []
            
            print("------ Total number of old posts: \(snapshot.childrenCount) ------")
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no post.")
                return
            }
            
            for item in allObjects {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    oldPosts.append(post)
                }
            }
            
            // Order in descending order (i.e. the latest post becomes the first post)
            oldPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completion(oldPosts)
        })
        
    }
    
    // MARK: - Download my posts for MyProfile
    // MARK: Observe posts' info for FeedVC
    
    func observeUserPost(postId: String, completion: @escaping (Post) -> Void) {
        
        // Filter via postId
        let postQuery = postsRef.child(postId)
        
        // Call Firebase API to retrieve the latest records
        postQuery.observe(.value, with: { (snapshot) in
            
            let postInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let newPost = Post(postId: snapshot.key, postInfo: postInfo) else {
                print("------ Post not found: \(snapshot.key) ------")
                return
            }
            
            print("------ newPost: \(newPost) ------")
            
            completion(newPost)
        })
    }
    
    // MARK: - Handle post's ❤️ (userDidLike)
    
    func updateUserDidLike(post: Post) {

        guard let userId = Auth.auth().currentUser?.uid else { return }
        var userDidLike = post.userDidLike
        
        if userDidLike.contains(userId) {
            let filtered = userDidLike.filter { $0 != userId }
            postsRef.child(post.postId).child("userDidLike").setValue(filtered)
            print("------ Dislike💔 ------")
            
        } else {
            userDidLike.append(userId)
            postsRef.child(post.postId).child("userDidLike").setValue(userDidLike)
            print("------ Like❤️ ------")
        }
    }
    
    // MARK: - Delete the Post
    
    func deletePost(postId: String, completion: @escaping () -> Void) {
        
        // Update local currentUser.posts
        guard let posts = userManager.currentUser?.posts else { return }
        let filtered = posts.filter { $0 != postId }
        userManager.currentUser?.posts = filtered
        print("------ userManager.currentUser.posts: \(filtered) ------")
        
        // Update /users/userId/posts on firebase
        guard let userId = Auth.auth().currentUser?.uid else { return }
        userManager.updateUserPosts {
            print("------ Delete /users/\(userId)/posts/\(postId) ------")
        }
        
        // Update /posts on firebase
        postsRef.child(postId).removeValue()
        print("------ Delete /posts/\(postId) ------")
        
        // Download posts & Reload data
        completion()
    }
}
