//
//  HomeEventCellViewModel.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import UIKit
import IGListKit
import SwiftDate


class EventCellViewModel: HomeCellViewModel {
    // Basic
    let id: String
    let event: Event
    let imageUrlString:String?
    let emojiString:String?
    let title:String
    let dateString:String
    let location:String
    let intro:String?
    let tag: [Tag]
    let participants:[Participant]
    let comments:[Comment]
    let organiser:User?
    var image:UIImage? = nil
    
    let eventStatus:EventStatus
    
    var isOrganiser:Bool = false
    var isJoined:Bool = false
    
    let headcount:Headcount
    let canJoin:Bool
    let allowWaitList:Bool
    
    let maleString:String
    let femaleString:String
    let totalString:String
    
    let peopleCount: (male:Int, female:Int)
    var totalPeopleCount:Int {
        peopleCount.male + peopleCount.female
    }
    
    var friends:[Participant] {
        RelationshipManager.shared.getFriendsFromParticipants(from: participants)
    }
    
    var participantsExcludFriends:[Participant] {
        participants.filter { participant in
            !friends.contains { friend in
                participant.username == friend.username
            }
        }
    }
    
    var numberOfFriends:Int {
        friends.count
    }
    
    
    init(event: Event) {
        self.id = event.id
        
        self.event = event
        
        var maleCount = 0
        var femaleCount = 0
        var nonBinaryCount = 0
        
        self.participants = event.participants.compactMap({$0.value})
        
        event.participants.forEach { key,value in
            switch value.gender {
            case genderType.male.rawValue:
                maleCount += 1
            case genderType.female.rawValue:
                femaleCount += 1
//            case genderType.nonBinary.rawValue:
//                nonBinaryCount += 1
            default:
                print("case not handled")
            }
        }
        
        self.totalString = event.headCountString().total
        self.maleString = event.headCountString().male
        self.femaleString = event.headCountString().female
         
        self.eventStatus = event.eventStatus
        
        
        // MARK: - Date
        self.dateString = event.getDateStringForCell()
        
        // MARK: - Others
        
        self.imageUrlString = event.imageUrlString.first
        self.title = event.title
        self.location = event.location.name
        self.tag = event.tags
        self.headcount = event.headcount
        self.peopleCount = (male:maleCount, female:femaleCount)
        
        self.emojiString = event.emojiTitle
        self.intro = event.introduction
        self.organiser = event.organisers.first
        self.canJoin = event.canJoinEvent()
        self.allowWaitList = event.allowWaitList
        self.comments = event.comments
        
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        self.isOrganiser = self.organiser?.username == username
        self.isJoined = event.isJoined
        
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? EventCellViewModel else { return false }
        return event.id == other.event.id
    }
    
}


