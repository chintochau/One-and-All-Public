//
//  ConverstaionObject.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-18.
//

import Foundation
import RealmSwift

class ConversationObject: Object {
    @Persisted(primaryKey: true) var channelId:String
    @Persisted var channelUrlString:String?
    @Persisted var participants = List<UserObject>()
    @Persisted var messages = List<MessageObject>()
    @Persisted var lastUpdated:Date? = nil
    
    var targetname:String {
        let username = UserDefaults.standard.string(forKey: "username")!
        for user in participants {
            if user.username != username {
                return user.username
            }
        }
        return ""
    }
}
