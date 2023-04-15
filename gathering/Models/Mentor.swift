//
//  Mentor.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-05.
//

import Foundation
import IGListKit

struct Mentor:Codable {
    var username:String
    var profileUrlString:String
    var name: String
    var email: String
    var phone: String
    var expertise: String
    var yearsOfExperience: Int
    var areaOfExpertise: String
    var bio: String
    var languagesSpoken: [String]
    var availability: String
    var location: Location
}


class MentorViewModel:HomeCellViewModel {
    
    var id: String
    let name:String
    let email:String
    let expertise:String
    let urlString:String
    let bio:String
    let phone:String
    
    init(mentor:Mentor) {
        self.id = mentor.username
        self.name = mentor.name
        self.email = mentor.email
        self.expertise = mentor.expertise
        self.urlString = mentor.profileUrlString
        self.bio = mentor.bio
        self.phone =  mentor.phone
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? MentorViewModel else {return false}
        return id == other.id
    }
}
