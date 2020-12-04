//
//  FirestoreManager.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import Firebase
import FirebaseFirestoreSwift

enum Result<T> {
    
    case success(T)
    
    case failure(Error)
}

// MARK:-

enum FirebaseError: String, Error {
    
    case decode = "Firebase decode error"
}

// MARK:-

struct Filter {
    
    let key: String
    
    let value: Any
}

// MARK:-

class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private init() {}
    
    // MARK:-
    
    var currentTimestamp: Timestamp {
        return Firebase.Timestamp()
    }
    
    // MARK:-
    
    func getCollection(name: String) -> CollectionReference {
        return Firestore.firestore().collection(name)
    }
    
    // MARK:-
    
    func listen(collectionName: String, completion: @escaping () -> Void) {
        let collection = getCollection(name: collectionName)
        
        collection.getDocuments { _, _ in
            completion()
        }
    }
    
    // MARK:-
    
    func decode<T: Codable>(_ dataType: T.Type, documents: [QueryDocumentSnapshot], completion: @escaping (Result<[T]>) -> Void) {
        
        var datas: [T] = []
        
        for document in documents {
            guard let data = try? document.data(as: dataType) else {
                completion(.failure(FirebaseError.decode))
                return
            }
            datas.append(data)
        }
        completion(.success(datas))
    }
    
    // MARK:-
    
    func read<T: Codable>(collectionName: String, dataType: T.Type, completion: @escaping (Result<[T]>) -> Void) {
        let collection = getCollection(name: collectionName)
        
        collection.getDocuments { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            self.decode(dataType, documents: querySnapshot.documents) { (result) in
                
                switch result {
                
                case .success(let data): completion(.success(data))
                    
                case .failure(let data): completion(.failure(data))
                }
            }
        }
    }
    
    // MARK:- Filter by only one condition
    
    func read<T: Codable>(collectionName: String, dataType: T.Type, filter: Filter, completion: @escaping (Result<[T]>) -> Void) {
        
        let collection = getCollection(name: collectionName)
        
        collection.whereField(filter.key, isEqualTo: filter.value).getDocuments { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            
            self.decode(dataType, documents: querySnapshot.documents) { (result) in
                
                switch result {
                
                case .success(let data): completion(.success(data))
                    
                case .failure(let error): completion(.failure(error))
                }
            }
        }
    }
    
    // MARK:-
    
    func save<T: Codable>(to document: DocumentReference, data dataType: T) {
        let encoder = Firestore.Encoder()
        
        do {
            let data = try encoder.encode(dataType)
            document.setData(data)
            
        } catch {
            print("Firebase save data error: ", error.localizedDescription)
        }
    }
    
    // MARK:-
    
    func update(collectionName: String, documentId: String, key: String, value: Any) {
        let document = getCollection(name: collectionName).document(documentId)
        document.updateData([key: value])
    }
}
