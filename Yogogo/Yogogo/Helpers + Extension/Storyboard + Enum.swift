//
//  Storyboard + Enum.swift
//  Yogogo
//
//  Created by prince on 2020/12/9.
//

import Foundation

enum StoryboardName: String {
    
    case main = "Main"
    
    case auth = "Auth"
    
    case camera = "Camera"
    
    case editProfile = "EditProfile"
    
    case chat = "Chat"
}

enum StoryboardId: String {
    
    case tabBarController = "TabBarController"
    
    case signInVC = "SignInVC"
    
    case pickUsernameVC = "PickUsernameVC"
    
    case pickProfilePhotoVC = "PickProfilePhotoVC"
    
    case cameraVC = "CameraVC"
    
    case editProfileNC = "EditProfileNC"
    
    case myProfileVC = "MyProfileVC"
    
    case userProfileVC = "UserProfileVC"
    
    case myPostVC = "MyPostVC"
    
    case chatVC = "ChatVC"
}
