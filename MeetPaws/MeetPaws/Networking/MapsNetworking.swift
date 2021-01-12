//
//  MapsNetworking.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import UIKit
import Firebase
import Mapbox
import CoreLocation

class MapsNetworking {
    
    static let shared = MapsNetworking()
    
    var mapsVC: MapsViewController!
    
    var userIds: [String] = []
    
    var usersDict: [String: User] = [:]
    
    let userLocationsRef = Database.database().reference().child("userLocations")
    
    let usersRef = Database.database().reference().child("users")
    
    // MARK: - observe Users to get userIds
    
    func getUserIds(completion: @escaping ([String]) -> Void) {
        
        print("------ observe Users to get userIds... ------")
        
        usersRef.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let users = snapshot.value as? [String: Any] else { return }
            
            var userIds: [String] = []
            
            for userId in users.keys {
                guard userId != Auth.auth().currentUser?.uid else { continue }
                
                // The userId should not be in the ignoreList
                if let ignoreList = UserManager.shared.currentUser?.ignoreList {
                    guard !ignoreList.contains(userId) else { continue }
                }
                
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
        guard let user = User(userId: userId, userInfo: values) else { return }
        completion(user)
    }
    
    // MARK: - observe User Location
    
    func observeUserLocation(user: User) {
        
        print("------ observe User Location... ------")
        
        // Check isMapLocationEnabled
        if user.isMapLocationEnabled {

            userLocationsRef.child(user.userId).observe(.value) { (snapshot) in
                
                guard let values = snapshot.value as? [String: Any] else { return }
                guard let latitude = values["latitude"] as? Double else { return }
                guard let longitude = values["longitude"] as? Double else { return }
                
                // Check distance -> only nearby users will appear
                guard let myLocation = MapsNetworking.map.userLocation?.coordinate else { return }
                let myCoordinate = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
                let userCoordinate = CLLocation(latitude: latitude, longitude: longitude)
                let distanceInKiloMeters = myCoordinate.distance(from: userCoordinate) / 1000
                
                if distanceInKiloMeters <= 5 {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.handleUserLocation(user, coordinate)
                }
            }
        } else {
            print("------ user.isMapLocationEnabled == false ------")
        }
    }
    
    // MARK: - handle User Location -> Add users' pin
    
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
    
    // MARK: - Remove all users' pin
    
    func removeAllAnnotations() {
        
        guard let annotations = mapsVC.mapView?.annotations else {
            print("Annotations Error")
            return
        }
        
        if annotations.count != 0 {
            for annotation in annotations {
                mapsVC.mapView?.removeAnnotation(annotation)
            }

        } else {
            return
        }
    }
}

// MARK: - Update my location regularly

extension MapsNetworking {
    
    static var mapTimer = Timer()
    
    static var map = MGLMapView()
    
    static let userManager = UserManager.shared
    
    static func startUpdatingUserLocation() {
        
        MapsNetworking.mapTimer = Timer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(MapsNetworking.updateCurrentLocation),
                                     userInfo: nil,
                                     repeats: true)
        
        RunLoop.current.add(MapsNetworking.mapTimer, forMode: RunLoop.Mode.common)
    }
    
    @objc static func updateCurrentLocation() {
        
        guard userManager.currentUser?.isMapLocationEnabled ?? false else { return }
        guard let currentLocation = MapsNetworking.map.userLocation?.coordinate else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("userLocations").child(userId)
        let values = ["longitude": currentLocation.longitude, "latitude": currentLocation.latitude]
        
        ref.updateChildValues(values)
    }
}
