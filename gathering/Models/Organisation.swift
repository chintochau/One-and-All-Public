//
//  Organisation.swift
//  One&All
//
//  Created by Jason Chau on 2023-04-05.
//

import Foundation
import IGListKit

struct Organisation: Codable {
    let id: String
    let name: String
    let description: String
    let profileImageUrl: String
    let type: OrganizationType
    let location: Location
    let contact: OrganizationContact
}

enum OrganizationType: String, Codable {
    case church = "教會 / 教堂"
    case ngo = "非政府組織 / 慈善機構"
    case communityCentre = "社區組織 / 社區服務中心"
    case sportsClub = "體育會 / 運動會"
    case languageExchangeGroup = "語言交流團體 / 語言交換組織"
    case professionalAssociation = "專業協會"
    case youthOrganization = "青年組織"
    case artAssociation = "藝術協會"
    // add more types as needed
}

struct OrganizationContact: Codable {
    let email: String
    let phone: String
    let website: String
}


class OrganisationViewModel: HomeCellViewModel {
    var id: String
    let name:String
    let intro:String
    let profileUrlString:String
    let type:String
    
    init(organisation:Organisation) {
        self.id = organisation.id
        self.name = organisation.name
        self.intro = organisation.description
        self.profileUrlString = organisation.profileImageUrl
        self.type = organisation.type.rawValue
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? OrganisationViewModel else {return false}
        return id == other.id
        
    }
    
    
}
