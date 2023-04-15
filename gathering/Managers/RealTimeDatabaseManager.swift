//
//  RealTimeDatabaseManager.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-14.
//
import Foundation
import FirebaseDatabase

struct RealtimeDatabaseManager {
    static let shared = RealtimeDatabaseManager()
    
    var databaseRef = Database.database().reference()
    
    func sendMessage(_ message: MessageObject) {
        let messageRef = databaseRef.child("messages").child(message.channelId)
        messageRef.setValue(message.toDictionary())
    }
    
    func observeMessages(completion: @escaping ([MessageObject]) -> Void) {
        let messagesRef = databaseRef.child("messages")
        messagesRef.observe(.value, with: { snapshot in
            var messages: [MessageObject] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let message = MessageObject.fromDictionary(dict) {
                    messages.append(message)
                }
            }
            completion(messages)
        })
    }
    
    func createChannel(targetUsername: String, type: ChannelType, members: [String]) {
        
        guard let username = DefaultsManager.shared.getCurrentUser()?.username else {return}
        let channelId = IdManager.shared.generateChannelIDFor(targetUsername: targetUsername)
        let newChannelRef = databaseRef.child("channels").child(channelId)
        
        var membersDict: [String: Bool] = [:]
        for memberId in members {
            membersDict[memberId] = true
        }
        
        let channel = Channel(channelId: channelId, name: channelId, type: .privateChat, members: [targetUsername,username])
        
        guard let channelData = channel.asDictionary() else {return}
        newChannelRef.setValue(channelData)
        
        for memberId in members {
            databaseRef.child("users").child(memberId).child("channels").updateChildValues([channelId: true])
        }
        
    }
    
    
    func getOrCreatePrivateChannel(targetUsername: String, completion: @escaping (String) -> Void) {
        
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        
        let username = user.username
        
        // Check if there's an existing private channel between the two users
        let currentuserChannelsRef = databaseRef.child("users").child(username).child("channels")
        let targetUserChannelsRef = databaseRef.child("users").child(targetUsername).child("channels")
        let channelId = IdManager.shared.generateChannelIDFor(targetUsername: targetUsername)
        
        currentuserChannelsRef.observeSingleEvent(of: .value) { (user1ChannelsSnapshot) in
            if let user1Channels = user1ChannelsSnapshot.value as? [String: Bool] {
                
                targetUserChannelsRef.observeSingleEvent(of: .value) { user2ChannelsSnapshot in
                    if let user2Channels = user2ChannelsSnapshot.value as? [String: Bool] {
                        for channelId in user1Channels.keys {
                            if user2Channels[channelId] == true {
                                // Found an existing private channel
                                completion(channelId)
                                return
                            }
                        }
                    }
                    // Create a new private channel if no existing channel is found
                    createChannel(targetUsername: targetUsername, type: .privateChat, members: [targetUsername,username])
                    completion(channelId)
                    
                }
            } else {
                // Create a new private channel if no existing channel is found
                createChannel(targetUsername: targetUsername, type: .privateChat, members: [targetUsername,username])
                completion(channelId)
                
            }
        }
    }
    
    func observeChannelsForUser(userId: String, completion: @escaping (DataSnapshot) -> Void) {
        let userChannelsRef = databaseRef.child(userId).child("channels")
        
        userChannelsRef.observe(.childAdded) { (snapshot) in
            completion(snapshot)
        }
    }

}


struct Channel:Codable {
    let channelId:String
    let name:String
    let type: ChannelType
    let members:[String]
    
}

enum ChannelType:String, Codable {
    case privateChat
    case groupChat
}
