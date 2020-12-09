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
    
    var mapsVC: MapsViewController!
    
    let database = Firestore.firestore()
    
//    func observeUserLocation() {
//        for user in Users.list {
//            guard user.isMapLocationEnabled ?? false else { continue }
//            
//            database.collection("userLocation")
//                .document(user.userId ?? "")
//                .addSnapshotListener { (documentSnapshot, error) in
//                    
//                guard let snap = documentSnapshot else {
//                    print("Error fetching document: \(error!)")
//                    return
//                }
//                    guard let latitude = snap.value(forKey: "latitude") as? Double else { return }
//                    guard let longitude = snap.value(forKey: "longitude") as? Double else { return }
//
//                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                    self.handleUserLocation(user, coordinate)
//            }
//        }
//    }
    
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
}
