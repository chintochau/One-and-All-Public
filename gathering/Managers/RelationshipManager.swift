//
//  RelationshipManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-21.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class RelationshipManager {
    static let shared = RelationshipManager()
    var listener:ListenerRegistration?
    
    func getFriendsFromParticipants(from participants:[Participant]) -> [Participant] {
        let realm = try! Realm()
        let friendsObjects = realm.objects(RelationshipObject.self)
        var friends = participants.filter { participant in
            friendsObjects.contains {
                ($0.targetUsername == participant.username) &&
                ($0.status == relationshipType.friend.rawValue)
            }
        }
        friends = friends.compactMap { participant in
            var friend = participant
            friend.isFriend  = true
            return friend
        }
        return friends
    }
    
    func getFriendsInUserObjects() -> [UserObject] {
        
        let realm = try! Realm()
        let relationship = realm.objects(RelationshipObject.self)
        
        var friendList = [UserObject]()
        for person in relationship {
            if person.status == relationshipType.friend.rawValue, let friend = person.targetUser {
                friendList.append(friend)
            }
        }
        
        return friendList
        
    }
    
    func getAllRelationshipInUserObjects() -> [UserObject] {
        
        let realm = try! Realm()
        let relationship = realm.objects(RelationshipObject.self)
        
        var friendList = [UserObject]()
        relationship.forEach({
            if let friend = $0.targetUser {
                friendList.append(friend)
            }
        })
        
        return friendList
        
    }
    
    
    func listenToRelationshipData() {
        let realm = try! Realm()
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let query = Firestore.firestore().collection("users").document(username).collection("relationship")
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Firestore error: \(error)")
                return
            }
            guard let snapshot = snapshot else {
                print("Empty snapshot")
                return
            }
            realm.beginWrite()
            
            for document in snapshot.documents {
                guard let relationship = RelationshipObject(with: document.data()) else {
                    print("Failed to convert to Object for document: \(document)")
                    return
                }
                
                realm.add(relationship, update: .modified)
            }
            try! realm.commitWrite()
            
        }
    }
    
    func observeFirebaseRelationshipsChangesIntoRealm(){
        listener?.remove()
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let collection = Firestore.firestore().collection("users/\(username)/relationship")
        var documents: [QueryDocumentSnapshot] = []

        collection.getDocuments { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                print("Error fetching collection: \(error)")
                return
            }
            documents = querySnapshot.documents
            
            // Observe changes to the collection
            self.listener = collection.addSnapshotListener { querySnapshot, error in
                guard let querySnapshot = querySnapshot else {
                    print("Error observing collection: \(error)")
                    return
                }
                
                // Find the changed document in the documents array
                for change in querySnapshot.documentChanges {
                    let document = change.document
                    let index = documents.firstIndex { $0.documentID == document.documentID }
                    
                    guard let relationship = RelationshipObject(with: document.data()) else {return}
                    
                    let realm = try! Realm()
                    realm.beginWrite()
                    
                    switch change.type {
                    case .added:
                        // New document added to the collection
                        documents.append(document)
                        realm.add(relationship,update: .modified)
                        print("Document added: \(document)")
                    case .modified:
                        // Existing document modified
                        if let index = index {
                            documents[index] = document
                            print("Document modified: \(document)")
                        }
                        realm.add(relationship,update: .modified)
                        
                    case .removed:
                        // Existing document removed from the collection
                        if let index = index {
                            documents.remove(at: index)
                            print("Document removed: \(document)")
                        }
                        
                        if let relationship = realm.object(ofType: RelationshipObject.self, forPrimaryKey: relationship.targetUsername) {
                            realm.delete(relationship)
                        }
                    }
                    
                    try! realm.commitWrite()
                    
                }
            }
        }
    }
}
