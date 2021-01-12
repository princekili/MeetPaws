//
//  AnnotationPin.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//

import Mapbox

class AnnotationPin: MGLPointAnnotation {
    
    var user: User!
    
    let calendar = Calendar(identifier: .gregorian)
    
    init(_ user: User, _ coordinate: CLLocationCoordinate2D) {
        super.init()
        self.user = user
        self.coordinate = coordinate
        self.title = user.username
        
        if user.isOnline {
            self.subtitle = "Online"
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval((user.lastLogin)))
            self.subtitle = calendar.calculateLastLogin(date as Date)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
