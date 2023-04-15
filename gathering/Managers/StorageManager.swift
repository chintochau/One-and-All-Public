//
//  StorageManager.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-13.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    let storage:StorageReference =  {
        let storage = Storage.storage()
//        storage.useEmulator(withHost: "localhost", port: 9199)
        return storage.reference()
    }()
    
    // MARK: - Upload Image
    public func uploadEventImage(id:String,data:[Data?], completion: @escaping ([String]) -> Void){
        let group = DispatchGroup()
        
        var urlInSequence:[(order:Int, url:String)] = []
        
        for index in 0..<data.count  {
            guard let imageData = data[index] else {
                continue
            }
            
            group.enter()
            let ref = storage.child("events/\(id)/\(id)_\(index).jpg")
            // Enter dispatch queue 1, total 3 at most
            
            ref.putData(imageData) { _, error in
                guard error == nil else {
                    group.leave()
                    return
                }
                ref.downloadURL { url, error in
                    guard let urlString = url?.absoluteString else {return}
                    urlInSequence.append((order: index, url: urlString))
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            let downloadUrls:[String] = urlInSequence.sorted { $0.order < $1.order }.compactMap({$0.url})
            completion(downloadUrls)
        }
    }
    
    public func deleteEventImages(id:String, completion:@escaping (Bool) -> Void) {
        
        let storageRef = Storage.storage().reference().child("events/\(id)")

        // List all items in the storage location
        storageRef.listAll { (result, error) in
            if let error = error {
                // Handle the error
                print("Error listing items: \(error.localizedDescription)")
                return
            }
            
            guard let items = result?.items, !items.isEmpty else {
                completion(true)
                return
            }
            
            // Loop through all items and delete them
            for item in items {
                item.delete { error in
                    if let error = error {
                        // Handle the error
                        print("Error deleting item: \(error.localizedDescription)")
                    } else {
                        // Item deleted successfully
                        print("Item deleted: \(item.name)")
                    }
                    
                    completion(error == nil)
                }
            }
        }
    }
    
    public func deleteUserProfileImage(id:String, completion:@escaping (Bool) -> Void) {
        
        let ref = storage.child("users/\(id)/profileImage.jpg")
        ref.delete { error in
            completion(true)
        }
        
    }
    
    
    public func uploadprofileImage(image:UIImage, completion: @escaping (String?) -> Void){
        
        guard let image = image.sd_resizedImage(with: CGSize(width: 1024, height: 1024), scaleMode: .aspectFill),
              let data = image.jpegData(compressionQuality: 0.5),
              let username = UserDefaults.standard.string(forKey: "username")
        else {return}
        
        let ref = storage.child("users/\(username)/profileImage.jpg")
        
        ref.putData(data) { _, error in
            
            guard error == nil else {
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                guard let urlString = url?.absoluteString else {
                    completion(nil)
                    return}
                
                completion(urlString)
                
            }
            
        }
    }
    
}
