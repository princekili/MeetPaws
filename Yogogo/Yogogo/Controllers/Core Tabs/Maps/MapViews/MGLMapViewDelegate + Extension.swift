//
//  MGLMapViewDelegate + Extension.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Mapbox

// MARK: User location annotation

extension MapsViewController: MGLMapViewDelegate {    
    
    // Substitute our custom view for the user location annotation.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        // Me
        if annotation is MGLUserLocation && mapView.userLocation != nil {
//            return CustomUserLocationAnnotationView()
            return CurrentUserAnnotationView()
            
        // Other users
        } else {
            guard let annotation = annotation as? AnnotationPin else { return nil }
            let reuseIdentifier = "UserAnnotation"
            return UserAnnotationView(annotation: annotation,
                                      reuseIdentifier: reuseIdentifier,
                                      user: annotation.user)
        }
    }
    
    // MARK: - didSelect - tap the user location annotation to toggle heading tracking mode.
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        mapView.setCenter(annotation.coordinate, zoomLevel: 16, animated: true)
        
        tabBarController?.tabBar.isHidden = true
        
        // Me
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            
            if mapView.userTrackingMode != .followWithHeading {
                mapView.userTrackingMode = .followWithHeading
            } else {
                mapView.resetNorth()
            }
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseIn,
                           animations: {
                            
                self.userInfoTab = UserInfoTab(annotation: annotation)
//                let tapGesture = UITapGestureRecognizer(target: self,
//                                                        action: #selector(self.openMapsSettings))
//                self.userInfoTab?.addGestureRecognizer(tapGesture)
//                self.userInfoTab?.actionButton.addTarget(self,
//                                                         action: #selector(self.openMapsSettings),
//                                                         for: .touchUpInside)
                self.view.addSubview(self.userInfoTab!)
            })
            
        // Other users
        } else {
            guard let pin = annotation as? AnnotationPin else { return }
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseIn,
                           animations: {
                            
                self.userInfoTab = UserInfoTab(annotation: pin)
//                let tapGesture = UITapGestureRecognizer(target: self,
//                                                        action: #selector(self.openUserMessagesHandler))
                self.selectedUser = pin.user
//                self.userInfoTab?.addGestureRecognizer(tapGesture)
//                self.userInfoTab?.actionButton.addTarget(self,
//                                                         action: #selector(self.openUserMessagesHandler),
//                                                         for: .touchUpInside)
                self.view.addSubview(self.userInfoTab!)
            })
        }
    }
    
    // MARK: - didDeselect
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        self.userInfoTab?.removeFromSuperview()
        self.userInfoTab = nil
        
        tabBarController?.tabBar.isHidden = false
    }
}
