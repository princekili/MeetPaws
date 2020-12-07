//
//  ProfileManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import Foundation

class ProfileManager {
    
    static let shared = ProfileManager()
    
    private init() {}
    
    var user
    
    var username: String?
}
