//
//  EventDetailsViewModel.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-27.
//

import UIKit
import IGListKit

class EventDetailsViewModel: ListDiffable {
    var id:String
    var name:String
    var owner:User?
    var dateString:String
    var timeString:String
    var locationString:String
    var intro:String?
    var location:Location
    
    init (event:Event) {
        self.id = event.id
        self.name = event.title
        self.owner = event.organisers.first
        self.dateString = event.getDateDetailString()
        self.timeString = event.getTimeString()
        
        var addressString = event.location.name
        
        if let address = event.location.address,address.count > 0 {
            addressString += ",\n\(address)"
        }
        
        self.locationString = addressString
        self.intro = event.introduction
        self.location = event.location
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? EventDetailsViewModel else {return false}
        return id == object.id
    }
}

class EventParticipantsViewModel :ListDiffable {
    
    var id:String = UUID().uuidString
    var numberOfParticipants:String
    var numberOfMale:String
    var numberOfFemale:String
    var friends:[Participant]
    var numberOfFriends:String
    var confirmedParticipants:[Participant]
    var signedUpParticipants:[Participant]
    var tag:Tag?
    
   
    init (event: Event) {
        
        self.friends = event.confirmedFriends
        
        self.confirmedParticipants = event.confirmedParticipants
        self.signedUpParticipants = event.allParticipants
        
        self.numberOfMale = event.headCountString().male
        self.numberOfFemale = event.headCountString().female
        self.numberOfParticipants = event.headCountString().total
        
        self.numberOfFriends = friends.count > 0 ? "你有\(friends.count)個朋友參加左: " : "參加者: "
        
        self.tag = event.tags.first
        
    }
    
    
    
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object  = object as? EventParticipantsViewModel else {return false}
        return id == object.id
    }
}
