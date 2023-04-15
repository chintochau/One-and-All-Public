//
//  UserEvent.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-22.
//

import Foundation


struct UserEvent:Codable {
    let id:String
    let name:String
    let imageUrlString:String?
    let startDateTimestamp:Double
    let endDateTimeStamp:Double
    let emojiString:String
    let organiser:String?
    let location:Location
    let eventStatus:EventStatus
    let description:String?
    var referencePath:String? = nil
    
    
    var dateString:String {
        let date = Date(timeIntervalSince1970: startDateTimestamp)
        
        let dateString = String.localeDate(from: date, .zhHantTW)
        
        return dateString.date
    }
}


struct UserEventViewModel {
    let title:String
    let location:String
    let date:String
    let urlString:String?
    let eventTag:Tag
    let emojiString:String
}


extension UserEvent {
    public func toViewModel() -> UserEventViewModel {
        
        var tagType:TagType = .grouped
        
        switch self.eventStatus {
        case .grouping:
            tagType = .grouping
        case .confirmed:
            tagType = .grouped
        case .activity:
            break
        case .cancelled:
            break
        }
        
        
        return UserEventViewModel(
            title: self.name,
            location: self.location.name,
            date: String.getDateStringForCell(startDate: self.startDateTimestamp.toDate(), endDate: self.endDateTimeStamp.toDate()),
            urlString: self.imageUrlString,
            eventTag: Tag(type: tagType),
            emojiString: self.emojiString
        )
        
    }
}

extension Event {
    // MARK: - public functions
    func toUserEvent () -> UserEvent {
        UserEvent(
            id: self.id,
            name: self.title,
            imageUrlString:self.imageUrlString.first,
            startDateTimestamp:self.startDateTimestamp,
            endDateTimeStamp: self.endDateTimestamp,
            emojiString:self.emojiTitle ?? "😃",
            organiser: self.organisers.first?.name,
            location: self.location,
            eventStatus: self.eventStatus,
            description: self.introduction,
            referencePath:self.referencePath
        )
        
    }
}
