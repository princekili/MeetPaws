//
//  AuthManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class UserManager {
    
    static let shared: UserManager = UserManager()
    
    private init() {}
    
    var username = "No Username" // for addUser()
    
    var profileImage = ""
    
    var currentUser: User?
    
    // MARK: Firebase Reference
    
    let ref: DatabaseReference = Database.database().reference()
    
    let usersRef: DatabaseReference = Database.database().reference().child("users")
    
    let profilePhotoStorageRef: StorageReference = Storage.storage().reference().child("profilePhotos")
    
    // MARK: - Check if first time sign in
    
    func checkFirstTimeSignIn(completion: @escaping (Bool?) -> Void) {
        
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            var isFirstTime = true
            
            let uid = Auth.auth().currentUser?.uid
            
            guard let allUsers = snapshot.children.allObjects as? [DataSnapshot] else {
                print("There's no user.")
                return
            }
            
            for user in allUsers {
                if user.key == uid {
                    isFirstTime = false
                    break
                } else {
                    isFirstTime = true
                }
            }
            completion(isFirstTime)
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
    
    // MARK: - Get the author info
    
    func getAuthorInfo(userId: String, completion: @escaping (User) -> Void) {
        
        // Call Firebase API to retrieve the user info
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("------ User not found ------")
                return
            }

            print("------ Get the post author info 'ID: \(user.username)' successfully ------")
            
            completion(user)
        }
    }
    
    // MARK: - Get the user info
    
    func getUserInfo(userId: String, completion: @escaping (User) -> Void) {
        
        // Call Firebase API to retrieve the user info
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            let userInfo = snapshot.value as? [String: Any] ?? [:]
            
            guard let user = User(userId: userId, userInfo: userInfo) else {
                print("------ User not found ------")
                return
            }
            
            // Save user info to local UserManager
            self.currentUser = user
            
            completion(user)
        }
    }
    
    // MARK: - Add a user on DB
    
    func addUser(image: UIImage, completion: @escaping () -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = ref.child("users").child(userId)
        
        // Use the unique key as the image name and prepare the storage reference
        guard let imageKey = userRef.key else { return }
        
        let imageStorageRef = profilePhotoStorageRef.child("\(imageKey).jpg")
        
        // Resize the image
        let scaledImage = image.scale(newWidth: 200)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.7) else { return }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // Prepare the upload task
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // Observe the upload status
        uploadTask.observe(.success) { (snapshot) in
            
            // Add a reference in the database
            snapshot.reference.downloadURL(completion: { (url, error) in
                
                let username = self.username
                
                guard let url = url else { return }
                let profileImage = url.absoluteString
                self.profileImage = profileImage
                
                let fullName = "Edit your name..."
                let bio = "Edit your bio..."
                let posts: [String] = [""]
                let followRequests: [String] = [""]
                let followers: [String] = [""]
                let following: [String] = [""]
                let postDidLike: [String] = [""]
                let bookmarks: [String] = [""]
                let ignoreList: [String] = [""]
                // MARK: - For test
//                let posts: [String] = ["-MO0EB0y1ajvJekzDzMJ"]
//                let followRequests: [String] = ["rYak2LOQTZR3y370Nx6hXHP5AhO2"]
//                let followers: [String] = ["rYak2LOQTZR3y370Nx6hXHP5AhO2"]
//                let following: [String] = ["rYak2LOQTZR3y370Nx6hXHP5AhO2"]
//                let postDidLike: [String] = ["-MO0EB0y1ajvJekzDzMJ"]
//                let bookmarks: [String] = ["-MO0EB0y1ajvJekzDzMJ"]
//                let ignoreList: [String] = ["rYak2LOQTZR3y370Nx6hXHP5AhO2"]
                // MARK: -
                let joinedDate = Int(Date().timeIntervalSince1970 * 1000)
                let lastLogin = Int(Date().timeIntervalSince1970 * 1000)
                let isPrivate = false
                let isOnline = true
                let isMapLocationEnabled = true
                
                let user: [String: Any] = [
                    "username": username,
                    "profileImage": profileImage,
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
   
    // MARK: - Update All User Info
    
    func updateAllUserInfo(completion: @escaping () -> Void) {

        print("------ Update local user info to DB ------")
        print(currentUser ?? "------ currentUser == nil ------")
        print("-----^ Update local user info to DB ^-----")

        // MARK: Update DB
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let username = currentUser?.username else { return }
        guard let profileImage = currentUser?.profileImage else { return }
        guard let fullName = currentUser?.fullName else { return }
        guard let bio = currentUser?.bio else { return }
        guard let posts: [String] = self.currentUser?.posts else { return }
        guard let followRequests: [String] = self.currentUser?.followRequests else { return }
        guard let followers: [String] = self.currentUser?.followers else { return }
        guard let following: [String] = self.currentUser?.following else { return }
        guard let postDidLike: [String] = self.currentUser?.postDidLike else { return }
        guard let bookmarks: [String] = self.currentUser?.bookmarks else { return }
        guard let ignoreList: [String] = self.currentUser?.ignoreList else { return }
        guard let joinedDate = self.currentUser?.joinedDate else { return }
        let lastLogin = Int(Date().timeIntervalSince1970 * 1000)
        guard let isPrivate = self.currentUser?.isPrivate else { return }
        guard let isOnline = self.currentUser?.isOnline else { return }
        guard let isMapLocationEnabled = self.currentUser?.isMapLocationEnabled else { return }

        let user: [String: Any] = [
            "username": username,
            "profileImage": profileImage,
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

        let childUpdates = ["\(userId)": user]

        self.ref.child("users").updateChildValues(childUpdates)

        completion() // do something after updating
    }
    
    // MARK: - Update User Profile Info
    
    func updateUserProfile(image: UIImage, fullName: String, username: String, bio: String, completion: @escaping () -> Void) {
        
        // MARK: Update local UserManager for instantly use
        currentUser?.fullName = fullName
        currentUser?.username = username
        currentUser?.bio = bio
        
        // MARK: Update DB
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = ref.child("users").child(userId)
        guard let imageKey = userRef.key else { return }
        let imageStorageRef = profilePhotoStorageRef.child("\(imageKey).jpg")
        
        let scaledImage = image.scale(newWidth: 200)
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.7) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)

        uploadTask.observe(.success) { (snapshot) in
            
            snapshot.reference.downloadURL { (url, error) in
                
                guard let url = url else { return }
                let profileImage = url.absoluteString
                
                // for local use
                self.profileImage = profileImage
                self.currentUser?.profileImage = profileImage
                
                let usernameUpdates = ["username": username]
                let profileImageUpdates = ["profileImage": profileImage]
                let fullNameUpdates = ["fullName": fullName]
                let bioUpdates = ["bio": bio]
                
                self.ref.child("users").child(userId).updateChildValues(usernameUpdates)
                self.ref.child("users").child(userId).updateChildValues(profileImageUpdates)
                self.ref.child("users").child(userId).updateChildValues(fullNameUpdates)
                self.ref.child("users").child(userId).updateChildValues(bioUpdates)
                
                print("------ Update Database ------")
                print(usernameUpdates)
                print(profileImageUpdates)
                print(fullNameUpdates)
                print(bioUpdates)
                print("------------")
            }
        }
        
        completion() // do something after updating
    }
    
    // MARK: - Update User Posts
    
    func updateUserPosts(completion: @escaping () -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let posts = self.currentUser?.posts else { return }
        
        let postsUpdate = ["posts": posts]
        
//        self.ref.child("users").child(userId).updateChildValues(postsUpdate)
        self.usersRef.child(userId).updateChildValues(postsUpdate)
        
        print("------ Update Database ------")
        print(postsUpdate)
        print("------------")
        
        completion() // do something after updating
    }
    
    // MARK: - Update Post Like Count
    
    func updateLikeCount(completion: @escaping () -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let postDidLike = self.currentUser?.postDidLike else { return }
        
        let postDidLikeUpdate = ["postDidLike": postDidLike]
        
        self.usersRef.child(userId).updateChildValues(postDidLikeUpdate)
        
        print("------ Update Database ------")
        print(postDidLikeUpdate)
        print("------------")
        
        completion() // do something after updating
    }
    
    // MARK: - Update isMapLocationEnabled
    
    func updateIsMapLocationEnabled() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let isMapLocationEnabled = self.currentUser?.isMapLocationEnabled else { return }
        
        let isMapLocationEnabledUpdate = ["isMapLocationEnabled": isMapLocationEnabled]
        
        self.usersRef.child(userId).updateChildValues(isMapLocationEnabledUpdate)
        
        print("------ Update Database ------")
        print("users/\(userId)/isMapLocationEnabled: \(isMapLocationEnabled)")
        print("------------")
    }
}
