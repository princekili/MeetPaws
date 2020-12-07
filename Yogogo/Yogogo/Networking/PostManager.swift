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
    
    // MARK: - Upload Image
    
    func uploadImage(image: UIImage, completion: @escaping () -> Void) {
        
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
            
//            guard let userDisplayName = Auth.auth().currentUser?.displayName else { return }
            let userDisplayName = Auth.auth().currentUser?.displayName
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else { return }
                
                // Add a reference in the database
                let imageFileURL = url.absoluteString
                
//                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                
                let post: [String: Any] = ["userId": userId,
                                            "userDisplayName": userDisplayName ?? "Unknown name",
                                            "imageFileURL": imageFileURL,
                                            "userDidLike": [],
                                            "caption": "",
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
}
