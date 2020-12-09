//
//  DatabaseManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AuthManager {
    
    static let shared: AuthManager = AuthManager()
    
    private init() {}
    
    // MARK: Firebase Reference
    
    let ref: DatabaseReference = Database.database().reference()
    
    let profilePhotoStorageRef: StorageReference = Storage.storage().reference().child("profilePhotos")
    
    // MARK: - Check if first time sign in
    
    func checkFirstTimeSignIn(completion: @escaping (Bool?) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            var isFirstTime: Bool?
            
            let uid = Auth.auth().currentUser?.uid
            
            guard let allUsers = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no user.")
                return
            }
            
            for user in allUsers {
                if user.key == uid {
                    isFirstTime = false
                } else {
                    isFirstTime = true
                }
            }
            completion(isFirstTime)
        }
    }
    
    // MARK: - Get the user info
    
    func getUserInfo(userId: String, completion: @escaping (User) -> Void) {
        
        // Call Firebase API to retrieve the user info
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("User not found!")
                return
            }
            
            // Save user info to UserDefaults
            UserDefaults.standard.setValue(user, forKey: "user")
            
//            if let data = UserDefaults.standard.object(forKey: "user") as? User {
//                data.username
//            }

            completion(user)
        }
    }
    
    // MARK: - Check if the username has been used
    
    func checkUsername(username: String, completion: @escaping (Bool?) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            var hasBeenUsed: Bool?
            
            guard let allUsers = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no user.")
                return
            }
            
            for user in allUsers {
                let value = user.value as? [String: Any] ?? [:]
                
                guard let valueUsername = value["username"] as? String else {
                    print("There's no username.")
                    return
                }
                
                if valueUsername == username {
                    hasBeenUsed = true
                } else {
                    hasBeenUsed = false
                }
            }
            completion(hasBeenUsed)
        }
    }
    
    // MARK: - Create the user info on DB (username, profile photo...)
    
    func addUser(username: String, image: UIImage, completion: @escaping () -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = ref.child("users").child(userId)
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = userRef.key else { return }
        
        let imageStorageRef = profilePhotoStorageRef.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 300)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.7) else { return }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Observe the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            let fullName = ""
            let bio = ""
            let posts: [String] = []
            let followRequests: [String] = []
            let followers: [String] = []
            let following: [String] = []
            let postDidLike: [String] = []
            let bookmarks: [String] = []
            let ignoreList: [String] = []
            let joinedDate = Int(Date().timeIntervalSince1970 * 1000)
            let lastLogin = Int(Date().timeIntervalSince1970 * 1000)
            let isPrivate = false
            let isOnline = true
            let isMapLocationEnabled = false
            
            snapshot.reference.downloadURL(completion: { (url, error) in
                
                let user: [String: Any] = [
                    "fullName": fullName,
                    "bio": bio,
                    "posts": posts,
                    "followRequests": followRequests,
                    "followers": followers,
                    "following": following,
                    "postDidLike": postDidLike,
                    "bookmarks": bookmarks,
                    "ignoreList": ignoreList,
                    "joinedDate": joinedDate,
                    "lastLogin": lastLogin,
                    "isPrivate": isPrivate,
                    "isOnline": isOnline,
                    "isMapLocationEnabled": isMapLocationEnabled
                ]
                
                userRef.setValue(user)
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
}
