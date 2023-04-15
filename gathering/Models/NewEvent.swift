//
//  NewEvent.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-22.
//

import Foundation
import SwiftDate


struct NewPost {
    var id:String = IdManager.shared.createEventId()
    var emojiTitle:String = UserDefaults.standard.string(forKey: "selectedEmoji") ?? "😃"
    var description: String = ""
    var intro:String? = nil
    var imageUrlString:String?
    var headcount:Headcount = .init()
    var eventStatus:EventStatus = .grouping
    
    var title:String = ""
    var addInfo:String? = nil
    var startDate:Date = Date.startOfTomorrowLocalTime() + 17.hours
    var endDate:Date = Date.startOfTomorrowLocalTime() + 17.hours
    var location:Location = .toBeConfirmed
    var participants:[String:Participant] = {
        guard let user = DefaultsManager.shared.getCurrentUser() else {
            return [:]
        }
        
        return [user.username:Participant(with: user,status: Participant.participantStatus.host)]
    }()
    var eventRef:String? = nil
    
    
    var autoApprove:Bool = true
    var allowWaitList:Bool = true
}

extension NewPost {
    func toEvent (_ urlStrings:[String] = []) -> Event? {
        guard let user = DefaultsManager.shared.getCurrentUser() else {return nil}
        
        var urlStrings = urlStrings
        
        if let imageUrlString = self.imageUrlString {
            if urlStrings == [] {
                urlStrings = [imageUrlString]
            }
        }
        
        return Event(id: self.id,
                     emojiTitle: self.emojiTitle,
                     title: self.title,
                     organisers: [user],
                     imageUrlString:urlStrings,
                     startDateTimestamp: self.startDate.timeIntervalSince1970,
                     endDateTimestamp: self.endDate.timeIntervalSince1970,
                     location: self.location,
                     presetTags: [],
                     introduction: self.intro,
                     participants: self.participants,
                     comments: [],
                     headcount: self.headcount,
                     ownerFcmToken: user.fcmToken,
                     eventStatus: self.eventStatus,
                     referencePath: self.endDate.yearDayStringUTC(),
                     autoApprove: self.autoApprove,
                     allowWaitList: self.allowWaitList
        )
    }
    
}

extension Event {
    func toNewPost()-> NewPost {
        return NewPost(
            id: self.id,
            emojiTitle: self.emojiTitle ?? "🤗",
            intro: self.introduction,
            imageUrlString: self.imageUrlString.first,
            headcount: self.headcount,
            title:self.title,
            addInfo:nil,
            startDate:self.startDate,
            endDate:self.endDate,
            location:self.location,
            participants:self.participants,
            eventRef: self.referencePath,
            autoApprove:self.autoApprove,
            allowWaitList: self.allowWaitList
        )
    }
}
