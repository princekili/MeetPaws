//
//  StorageManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import Foundation
import FirebaseStorage

enum StorageFolder: String {
    
    case user
    
    case post
    
    case message
}

class StorageManager {
    
    static let shared = StorageManager()
    
    private init() {}
    
    func uploadImage(images: [UIImage], folderName: StorageFolder, completion: @escaping (Result<String>) -> Void) {
            
        for image in images {
            
            let storageRef =
                Storage.storage().reference()
                .child(folderName.rawValue)
                .child(NSUUID().uuidString)
            
            guard let data = image.jpegData(compressionQuality: 0.7) else { return }
            
            storageRef.putData(data, metadata: nil) { (data, error) in
                if error != nil {
                    completion(.failure(error!))
                    print("Storage putData error: ", error!.localizedDescription)
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if error != nil {
                        completion(.failure(error!))
                        print("Storage download error: ", error!.localizedDescription)
                        return
                    }
                    
                    guard let url = url else {
                        completion(.failure(error!))
                        print("Storage download url error: ", error!.localizedDescription)
                        return
                    }
                    
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
    
}
