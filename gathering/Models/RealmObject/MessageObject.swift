//
//  Message.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-18.
//

import Foundation
import RealmSwift

class MessageObject: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var text = ""
    @Persisted var sentDate = Date()
    @Persisted var sender: UserObject?
    @Persisted var channelId:String

    var isIncoming:Bool {
        return sender?.username != UserDefaults.standard.string(forKey: "username")
    }
    
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "sender": sender?.toDictionary() ?? [:],
            "text": text,
            "timestamp": sentDate.timeIntervalSince1970
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> MessageObject? {
        guard let id = dict["id"] as? String,
              let sender = dict["sender"] as? UserObject,
              let text = dict["text"] as? String,
              let timestamp = dict["timestamp"] as? Double else {
            return nil
        }
        
        let message = MessageObject()
        message.text = text
        message.id =  id
        message.sentDate = timestamp.toDate()
        message.sender = sender
        
        
        
        return message
    }
}
