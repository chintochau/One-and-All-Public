//
//  ViewModel.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import Foundation
import IGListKit

protocol HomeCellViewModel: ListDiffable {
    var id: String { get }
}

class SkeletonViewModel: HomeCellViewModel {
    let id: String
    
    init() {
        self.id = UUID().uuidString
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? SkeletonViewModel else { return false }
        return id == other.id
    }
    
    // Additional properties and methods for the ad view model
}

class HomeMessageViewModel: HomeCellViewModel {
    var id: String
    let message:String
    let urlString:String?
    
    init(message:String, urlString:String? = nil) {
        self.id = UUID().uuidString
        self.message = message
        self.urlString = urlString
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? HomeMessageViewModel else {return false}
        return id == other.id
        
    }
}


class AdViewModel: HomeCellViewModel {
    let id: String
    let ad: Ad
    
    init(ad: Ad) {
        self.id = "ad_\(ad.id)"
        self.ad = ad
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? AdViewModel else { return false }
        return ad.id == other.ad.id
    }
    
    // Additional properties and methods for the ad view model
}

class PeopleViewModel: HomeCellViewModel {
    let id: String
    let person: Person
    
    init(person: Person) {
        self.id = "person_\(person.id)"
        self.person = person
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? PeopleViewModel else { return false }
        return person.id == other.person.id
    }
    
    // Additional properties and methods for the people view model
}

class PlaceViewModel: HomeCellViewModel {
    let id: String
    let place: Place
    
    init(place: Place) {
        self.id = "place_\(place.id)"
        self.place = place
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? PlaceViewModel else { return false }
        return place.id == other.place.id
    }
    
    // Additional properties and methods for the place view model
}

class HeaderViewModel:HomeCellViewModel {
    let id: String
    let header: Header
    
    init(header: Header) {
        self.id = "header_\(header.id)"
        self.header = header
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? HeaderViewModel else { return false }
        return header.id == other.header.id
    }
    
    
}

struct Place {
    let id:String
}

struct Person {
    let id:String
}

struct Ad {
    let id:String
}

struct Header {
    let id:String
    let title:String
}
