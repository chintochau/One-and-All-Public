//
//  Participants.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-30.
//

import Foundation



struct Participant:Codable {
    let name:String
    var username:String? = nil
    let gender:String
    var profileUrlString:String? = nil
    var joinStatus:participantStatus = .going
    var contact:String? = nil
    var isFriend:Bool? = nil
    
    enum participantStatus:Int,Codable {
        case host
        case going
        case quit
        case waitList
        case pending
        case rejected
    }
    
}

extension Participant {
    init(with user:User,status:participantStatus = .going){
        guard let name = user.name, let gender = user.gender else {
            fatalError("Name / Gender is nil")}
        self.name = name
        self.username = user.username
        self.gender = gender
        self.profileUrlString = user.profileUrlString
        self.joinStatus = status
    }
    
}
