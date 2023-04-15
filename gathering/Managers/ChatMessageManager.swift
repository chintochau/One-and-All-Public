//
//  ChatMessageManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-17.
//

import Foundation
import PubNub
import RealmSwift


struct Message : JSONCodable {
    let text:String
}

struct ChatMessageManager {
    static var shared = ChatMessageManager()
    
    var username = UserDefaults.standard.string(forKey: "username")
    
    var pubnub:PubNub?
    //    = {
    //        print("Current Pubnub User: \(username)")
    //        let config = PubNubConfiguration(
    //            publishKey: "pub-c-1e30f6e1-a29f-4a4d-ac62-01bf0a141150",
    //            subscribeKey: "sub-c-bb25b314-3fc0-48d7-ae4a-5bd2ca17abf2",
    //            userId: username)
    //        return PubNub(configuration: config)
    //    }()
    
    let listener:SubscriptionListener = {
        let listener = SubscriptionListener()
        return listener
    }()
    
    
    // MARK: - Initial
    public mutating func connectToChatServer(_ createChatGroup:Bool){
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            print("failed to connect to server")
            return}
        
        let config = PubNubConfiguration(
            publishKey: "pub-c-1e30f6e1-a29f-4a4d-ac62-01bf0a141150",
            subscribeKey: "sub-c-bb25b314-3fc0-48d7-ae4a-5bd2ca17abf2",
            userId: username)
        
        pubnub = PubNub(configuration: config)
        guard let pubnub = pubnub else {return}
        
        if createChatGroup {
            // create a creation channel and a channel group
            let initialMessage = Message(text: "Welcome to Gather!")
            sendMessageToChannel(channel: username, message: initialMessage) {[self] channel in
                addChannelToGroup(channel: username, group: username) { channel in
                    
                    listener.didReceiveMessage  = { message in
                        addPNMessageToRealm(message)
                    }
                    pubnub.add(listener)
                    pubnub.subscribe(to: [],and: [channel])
                }
            }
        }else {
            // connect to existing channel group
            listener.didReceiveMessage  = { [self] message in
                addPNMessageToRealm(message)
            }
            pubnub.add(listener)
            pubnub.subscribe(to: [],and: [username])
        }
        
    }
    
    private func sendMessageToChannel(channel:String, message:Message, completion: ((_ channel:String) -> Void)? = nil){
        guard let pubnub = pubnub else {return}
        
        pubnub.publish(channel: channel, message: message) { result in
            switch result {
            case .success(_):
                completion?(channel)
            case .failure(_):
                print("Failed")
            }
        }
    }
    
    private func addChannelToGroup( channel:String, group:String , completion: ((_ group:String) -> Void)? = nil) {
        
        guard let pubnub = pubnub else {return}
        pubnub.add(channels: [channel], to: group) { result in
            switch result {
            case .success((let group, let channels)):
                print("success add channel \(channels) to \(group)")
                completion?(group)
            case .failure(_):
                print("Failed add channel to group")
            }
        }
    }
    
    
    // MARK: - Deinit
    ///should call when user logout
    public func disconnectFromChatServer(){
        guard let pubnub = pubnub else {return}
        pubnub.unsubscribeAll()
    }
    
    
    // MARK: - Connect and Listen to Channel Group
    //    public func ConnectToChatServer(){
    //
    //        guard let username = UserDefaults.standard.string(forKey: "username") else {
    //            return
    //        }
    //
    //        listener.didReceiveMessage = { message in
    //            addPNMessageToRealm(message)
    //        }
    //
    //        pubnub.add(listener)
    //        pubnub.subscribe(to: [],and: [username])
    //
    //    }
    
    // MARK: - listen and Receive message
    public func listenToChannel(targetUsername:String) {
        
        guard let pubnub = pubnub else {return}
        
        let messageQueue = DispatchQueue(label: "pubnub-message-queue")
        
        let channelId = generateChannelIDFor(targetUsername: targetUsername)
        
        listener.didReceiveMessage = { message in
            addPNMessageToRealm(message)
        }
        
        pubnub.add(listener)
        pubnub.subscribe(to: [channelId], withPresence: true)
    }
    
    
    // MARK: - + PN Message to Realm
    public func addPNMessageToRealm(_ PNmessage: PubNubMessage){
        
        guard let pubnub = pubnub else {return}
        if let text = PNmessage.payload[rawValue: "text"] as? String,
           let sender = PNmessage.publisher{
            let message = MessageObject()
            let user = RealmManager.shared.createUserIfNotExist(username: sender)
            message.sender = user
            message.text = text
            message.sentDate = PNmessage.published.timetokenDate
            message.channelId = PNmessage.channel
            
            
            let realm = try! Realm()
            // Check if a conversation with the given ID already exists
            guard let senderUsername = message.sender?.username else {return}
            if let conversation = getConversationWithMessage(sender: senderUsername, channelid: message.channelId) {
                try! realm.write({
                    conversation.messages.append(message)
                    conversation.lastUpdated = message.sentDate
                })
                triggerInAppNotification(message: message)
            }
            
            
        }
    }
    
    // MARK: - Create Conversation
    /// get conversation with username
    public func getInitialConversationWithUsername(targetUsername:String) -> ConversationObject? {
        let realm = try! Realm()
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        
        let channelid = generateChannelIDFor(targetUsername: targetUsername)
        
        if let conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: channelid) {
            return conversation
        } else {
            let user1 = RealmManager.shared.createUserIfNotExist(username: username)
            let user2 = RealmManager.shared.createUserIfNotExist(username: targetUsername)
            
            let conversation = ConversationObject()
            conversation.participants.append(objectsIn: [user1,user2])
            conversation.channelId = channelid
            
            try! realm.write({
                realm.add(conversation)
            })
            
            return realm.object(ofType: ConversationObject.self, forPrimaryKey: channelid)
        }
    }
    
    /// get conversation with PN Message
    public func getConversationWithMessage(sender:String,channelid:String) -> ConversationObject? {
        
        let realm = try! Realm()
        guard let username = UserDefaults.standard.string(forKey: "username") else { return nil}
        
        if let conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: channelid),
           sender == username { return conversation
        } else if let conversation = realm.object(ofType: ConversationObject.self, forPrimaryKey: channelid) {
            return conversation
        } else {
            let user1 = RealmManager.shared.createUserIfNotExist(username: username)
            let user2 = RealmManager.shared.createUserIfNotExist(username: sender)
            
            let conversation = ConversationObject()
            conversation.participants.append(objectsIn: [user1,user2])
            conversation.channelId = channelid
            
            try! realm.write({
                realm.add(conversation)
            })
            
            return realm.object(ofType: ConversationObject.self, forPrimaryKey: channelid)
        }
    }
    
    
    
    // MARK: - Send message
    public func sendMessageToUser(targetUsername:String, text:String){
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let channelId = generateChannelIDFor(targetUsername: targetUsername)
        let message = Message(text: text)
        
        sendMessageToChannel(channel: channelId, message: message) { channel in
            addChannelToGroup(channel: channel, group:targetUsername)
            addChannelToGroup(channel: channel, group: username)
        }
        
        
        // Publish the message to the channel
        //        pubnub.publish(
        //            channel: channelId, message: Message(text: text), completion: { result in
        //                switch result {
        //                case .success(_):
        //                    pubnub.add( channels: [channelId], to: username
        //                    ) { result in
        //                        switch result {
        //                        case let .success(response):
        //                            print("success\(response)")
        //                            pubnub.subscribe( to: [channelId],and: [username],withPresence: true)
        //                        case let .failure(error):
        //                            print("failed: \(error.localizedDescription)")
        //                        }
        //                    }
        //                    pubnub.add(channels: [channelId], to: targetUsername) { result in
        //                        switch result {
        //                        case let .success(response):
        //                            print("success\(response)")
        //                        case let .failure(error):
        //                            print("Failed: \(error.localizedDescription)")
        //                        }
        //                    }
        //                case let .failure(error):
        //                    print("Fail message: \(error)")
        //                }
        //            })
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
    
    
    // MARK: - In-app notification
    public func triggerInAppNotification(message:MessageObject){
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let senderName = message.sender?.username,
              username != senderName else {return}
        
        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = message.text
        content.sound = UNNotificationSound.default
        content.userInfo = ["view": "MyViewController"]
        
        let request = UNNotificationRequest(identifier: "myNotification", content: content, trigger: nil)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("Error adding notification request: \(error.localizedDescription)")
            }
        }
    }
    
    
    
}
