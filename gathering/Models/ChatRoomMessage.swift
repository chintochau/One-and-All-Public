//
//  ChatRoomMessage.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-14.
//

import UIKit

struct ChatRoomMessage:Codable{
    let eventName:String
    let eventId:String
    let senderUsername:String
    let senderName:String
    let message:String
    let referencePath:String
}
