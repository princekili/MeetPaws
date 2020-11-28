//
//  ViewController.swift
//  Yogogo
//
//  Created by prince on 2020/11/26.
//
//  MapsVC is responsible for showing location of users' online friends.

import UIKit
import Mapbox

class MapVC: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView?
    var preciseButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

//        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
//        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let latitude = 25.042523125298583
        let longitude = 121.5648858334537
        mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), zoomLevel: 24, animated: true)
        mapView.delegate = self
        mapView.showsUserLocation = true
        self.mapView = mapView

        view.addSubview(mapView)
    }

    /**
        In order to enable the alert that requests temporary precise location,
        please add the following key to your info.plist
        `NSLocationTemporaryUsageDescriptionDictionary`

        You must then add
        `MGLAccuracyAuthorizationDescription`
        as a key in the Privacy - Location Temporary Usage Description Dictionary
     */
    @available(iOS 14, *)
    func mapView(_ mapView: MGLMapView, didChangeLocationManagerAuthorization manager: MGLLocationManager) {
        guard let accuracySetting = manager.accuracyAuthorization?() else { return }

        if accuracySetting == .reducedAccuracy {
            addPreciseButton()
        } else {
            removePreciseButton()
        }
    }

    @available(iOS 14, *)
    func addPreciseButton() {
        let preciseButton = UIButton(frame: CGRect.zero)
        preciseButton.setTitle("Turn Precise On", for: .normal)
        preciseButton.backgroundColor = .gray

        preciseButton.addTarget(self, action: #selector(requestTemporaryAuth), for: .touchDown)
        self.view.addSubview(preciseButton)
        self.preciseButton = preciseButton

        // constraints
        preciseButton.translatesAutoresizingMaskIntoConstraints = false
        preciseButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        preciseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        preciseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0).isActive = true
        preciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @available(iOS 14, *)
    @objc private func requestTemporaryAuth() {
        guard let mapView = self.mapView else { return }

        let purposeKey = "MGLAccuracyAuthorizationDescription"
        mapView.locationManager.requestTemporaryFullAccuracyAuthorization!(withPurposeKey: purposeKey)
    }

    private func removePreciseButton() {
        guard let button = self.preciseButton else { return }
        button.removeFromSuperview()
        self.preciseButton = nil
    }
}
