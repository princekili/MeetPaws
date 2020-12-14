//
//  MapsNetworking.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import UIKit
import Firebase
import Mapbox

class MapsNetworking {
    
    static let shared = MapsNetworking()
    
    var mapsVC: MapsViewController!
    
    var userIds: [String] = []
    
    var usersDict: [String: User] = [:]
    
    let userLocationsRef = Database.database().reference().child("userLocations")
    
    let usersRef = Database.database().reference().child("users")
    
    // MARK: - observe Users to get userIds
    
    func observeUsers(completion: @escaping ([String]) -> Void) {
        
        print("------ observe Users to get userIds... ------")
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let users = snapshot.value as? [String: Any] else { return }
            
            var userIds: [String] = []
            
            for userId in users.keys {
                guard userId != Auth.auth().currentUser?.uid else { continue }
                userIds.append(userId)
                print("------ userId: \(userId) ------")
            }
            completion(userIds)
        }
    }
    
    // MARK: - get User Info
    
    func getUserInfo(userId: String, completion: @escaping (String, [String: Any]) -> Void) {
        
        print("------ get User Info... ------")
        
        usersRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let values = snapshot.value as? [String: Any] else { return }
            
            completion(userId, values)
        }
    }
    
    // MARK: - decode User = setup User Info
    
    func decodeUser(userId: String, values: [String: Any], completion: @escaping (User) -> Void) {
        
        guard let username = values["username"] as? String else { return }
        guard let profileImage = values["profileImage"] as? String else { return }
        guard let fullName = values["fullName"] as? String else { return }
        guard let bio = values["bio"] as? String else { return }
        guard let posts = values["posts"] as? [String] else { return }
        guard let followRequests = values["followRequests"] as? [String] else { return }
        guard let followers = values["followers"] as? [String] else { return }
        guard let following = values["following"] as? [String] else { return }
        guard let postDidLike = values["postDidLike"] as? [String] else { return }
        guard let bookmarks = values["bookmarks"] as? [String] else { return }
        guard let ignoreList = values["ignoreList"] as? [String] else { return }
        guard let joinedDate = values["joinedDate"] as? Int else { return }
        guard let lastLogin = values["lastLogin"] as? Int else { return }
        guard let isPrivate = values["isPrivate"] as? Bool else { return }
        guard let isOnline = values["isOnline"] as? Bool else { return }
        guard let isMapLocationEnabled = values["isMapLocationEnabled"] as? Bool else { return }
        
        let user = User(userId: userId,
                        username: username,
                        profileImage: profileImage,
                        fullName: fullName,
                        bio: bio,
                        posts: posts,
                        followRequests: followRequests,
                        followers: followers,
                        following: following,
                        postDidLike: postDidLike,
                        bookmarks: bookmarks,
                        ignoreList: ignoreList,
                        joinedDate: joinedDate,
                        lastLogin: lastLogin,
                        isPrivate: isPrivate,
                        isOnline: isOnline,
                        isMapLocationEnabled: isMapLocationEnabled
        )
        usersDict[userId] = user
        print("------ Users.list.append(user) ------")
        print(user)
        
        completion(user)
    }
    
    // MARK: - observe User Location
    
    func observeUserLocation(user: User) {
        
        print("------ observe User Location... ------")
        
        // Add users' pin
        if user.isMapLocationEnabled {
            
            userLocationsRef.child(user.userId).observe(.value) { (snapshot) in
                
                guard let values = snapshot.value as? [String: Any] else { return }
                guard let latitude = values["latitude"] as? Double else { return }
                guard let longitude = values["longitude"] as? Double else { return }
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.handleUserLocation(user, coordinate)
            }
            
        // Remove users' pin
        } else {
        
            userLocationsRef.child(user.userId).observe(.value) { (snapshot) in
                
                guard let values = snapshot.value as? [String: Any] else { return }
                guard let latitude = values["latitude"] as? Double else { return }
                guard let longitude = values["longitude"] as? Double else { return }
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                self.removeUserPin(user, coordinate)
            }
        }
    }
    
    // MARK: - handle User Location
    
    func handleUserLocation(_ user: User, _ coordinate: CLLocationCoordinate2D) {

        let userPin = AnnotationPin(user, coordinate)
        var annotationToRemove: AnnotationPin!
        
        let status = mapsVC.mapView?.annotations?.contains(where: { (annotation) -> Bool in
            guard let oldAnnotation = annotation as? AnnotationPin else { return false }
            annotationToRemove = oldAnnotation
            
            return oldAnnotation.user.userId == userPin.user.userId
        })
        
        if status ?? false {
            mapsVC.mapView?.removeAnnotation(annotationToRemove)
        }
        
        mapsVC.userCoordinates[user.userId] = coordinate
        mapsVC.mapView?.addAnnotation(userPin)
        
        if mapsVC.isUserSelected && mapsVC.selectedUser?.userId != nil {
            guard let coordinate = mapsVC.userCoordinates[mapsVC.selectedUser!.userId] else { return }
            mapsVC.mapView?.setCenter(coordinate, zoomLevel: 16, animated: true)
        }
    }
    
    func removeUserPin(_ user: User, _ coordinate: CLLocationCoordinate2D) {
        
        let userPin = AnnotationPin(user, coordinate)
        mapsVC.userCoordinates[user.userId] = coordinate
        mapsVC.mapView?.removeAnnotation(userPin)
    }
}

// MARK: - Remove all users' pin

extension MapsNetworking {
    
    func removeUserLocation(user: User) {
        
        print("------ remove User Location... ------")
        
        userLocationsRef.child(user.userId).observe(.value) { (snapshot) in
            
            guard let values = snapshot.value as? [String: Any] else { return }
            guard let latitude = values["latitude"] as? Double else { return }
            guard let longitude = values["longitude"] as? Double else { return }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.removeUserPin(user, coordinate)
        }
    }
}
