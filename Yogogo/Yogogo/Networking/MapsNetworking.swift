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
    
    var mapsVC: MapsVC!
    
    let database = Firestore.firestore()
    
    func observeUserLocation() {
        for user in Users.list {
            guard user.isMapLocationEnabled ?? false else { continue }
            
            database.collection("userLocation")
                .document(user.id ?? "")
                .addSnapshotListener { (documentSnapshot, error) in
                    
                guard let snap = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                    guard let latitude = snap.value(forKey: "latitude") as? Double else { return }
                    guard let longitude = snap.value(forKey: "longitude") as? Double else { return }

                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.handleFriendLocation(user, coordinate)
            }
        }
    }
    
    func handleFriendLocation(_ user: User, _ coordinate: CLLocationCoordinate2D) {
        let userPin = AnnotationPin(user, coordinate)
        var annotationToRemove: AnnotationPin!
        
        let status = mapsVC.mapView?.annotations?.contains(where: { (annotation) -> Bool in
            guard let oldAnnotation = annotation as? AnnotationPin else { return false }
            annotationToRemove = oldAnnotation
            
            return oldAnnotation.user.id == userPin.user.id
        })
        if status ?? false {
            mapsVC.mapView?.removeAnnotation(annotationToRemove)
        }
        mapsVC.userCoordinates[user.id ?? ""] = coordinate
        mapsVC.mapView?.addAnnotation(userPin)
        
        if mapsVC.isUserSelected && mapsVC.selectedUser.id != nil {
            guard let coordinate = mapsVC.userCoordinates[mapsVC.selectedUser.id!] else { return }
            mapsVC.mapView?.setCenter(coordinate, zoomLevel: 16, animated: true)
        }
    }
}
