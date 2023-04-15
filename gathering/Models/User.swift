//
//  User.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import Foundation

struct User :Codable{
    let username:String
    let email:String?
    let name:String?
    let profileUrlString:String?
    let gender:String?
    var birthday:Date?
    var rating:Double? = nil
    var fcmToken:String? = nil
    var chatToken:String? = nil
    var interests:[String]? = []
    var contacts:Contacts? = nil
    var immigrantStatus: ImmigrantStatus? = nil
}

enum ImmigrantStatus:Codable {
    case bornInCanada
    case PR(year: Date)
    case other(year: Date)
}

extension User {
    init?(with participant:Participant){
        guard let username = participant.username else {return nil}
        
        self.username = username
        self.name = participant.name
        self.profileUrlString = participant.profileUrlString
        self.gender = participant.gender
        self.email = nil
    }
    
}


struct Contacts:Codable {
    let instagram:String?
    let telegram:String?
    let phone:String?
}


struct TempProfile {
    var name:String = ""
    var gender:String = genderType.male.rawValue
}

enum personalityType:String {
    case openness = "Openness"
    case conscientiousness = "Conscientiousness"
    case extraversion = "Extraversion"
    case agreeableness = "Agreeableness"
    case neuroticism = "Neuroticism"
}

enum genderType:String,CaseIterable {
    case male
    case female
}

