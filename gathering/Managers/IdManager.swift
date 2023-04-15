//
//  IdManager.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-16.
//

import Foundation

final class IdManager  {
    static let shared = IdManager()
    
    public func createEventId () -> String {
        let id = UUID().uuidString.prefix(8)
        let dateString = Int(Date().timeIntervalSince1970)/5000
        let randomNumber = Int.random(in: 1...1000)
        return "\(dateString)_\(id)"
    }
    
    // MARK: - Channel ID
    public func generateChannelIDFor(targetUsername:String) -> String{
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            print("Failed to create event ID")
            return ""
        }
        let sortedUsername = [username,targetUsername].sorted()
        
        return "messages_\(sortedUsername[0])_to_\(sortedUsername[1])"
    }
    
    public func generateRelationshipIdFor(targetUsername:String) -> (id:String,user1:String,user2:String)?{
        guard let username = UserDefaults.standard.string(forKey: "username") else {fatalError()}
        
        let sortedUsername = [username, targetUsername].sorted()
        
        return (sortedUsername[0] + "_" + sortedUsername[1], sortedUsername[0],sortedUsername[1])
        
    }
    
    // MARK: - EventInviteId
    public func createInviteId(targetUsername:String, eventId:String) -> String{
        guard let user = DefaultsManager.shared.getCurrentUser() else {return UUID().uuidString}
        return "\(user.username)_\(targetUsername)_\(eventId)"
    }
    
    public func createFriendRequestID(targetUsername:String) -> String {
        guard let user = DefaultsManager.shared.getCurrentUser() else {return UUID().uuidString}
        
        return "\(user.username)_\(targetUsername)"
        
    }
    
}
