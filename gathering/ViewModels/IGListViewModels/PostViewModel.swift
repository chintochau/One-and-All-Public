//
//  PostViewModel.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-25.
//

import Foundation
import IGListKit

class PostViewModel: HomeCellViewModel {
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
    let organiser:User?
    
    var isOrganiser:Bool = false
    var isJoined:Bool = false
    
    let headcount:Headcount
    let headcountString:String
    
    
    let maleString:String
    let femaleString:String
    let totalString:String
    
    let peopleCount: (male:Int, female:Int)
    var totalPeopleCount:Int {
        peopleCount.male + peopleCount.female
    }
    
    
    init(event: Event) {
        self.id = event.id
        self.event = event
        
        
        
        // MARK: - HeadCount
        var maleCount = 0
        var femaleCount = 0
        var nonBinaryCount = 0
        
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
        
        let headcount = event.headcount
        let total:String = headcount.max == 0 ? "" : "/\(headcount.max)"
        let female:String = headcount.fMax == 0 ? "" : "/\(headcount.fMax)"
        let male:String = headcount.mMax == 0 ? "" : "/\(headcount.mMax)"
        
        self.totalString = "\(maleCount + femaleCount)\(total)"
        self.maleString = "\(maleCount)\(male)"
        self.femaleString = "\(femaleCount)\(female)"
        
        var headCountString = "成團人數\n"
        
        if headcount.isEmpty() {
            headCountString += "任意"
        }else if event.headcount.isGenderSpecific {
            let maleString:String = headcount.mMin == 0 ? "" : "\(headcount.mMin)男"
            let femaleString:String = headcount.fMin == 0 ? "" : "\(headcount.fMin)女"
            headCountString += "\(maleString) \(femaleString)"
        } else {
            headCountString += headcount.min == 0 ? "任意" : "\(headcount.min)人"
        }
        
        self.headcountString = headCountString
         
        
        // MARK: - Date
        var finalDateString:String = ""
        var startString:String = ""
        var endString:String = ""
        let startDateString = String.localeDate(from: event.startDateString, .zhHantTW)
        let endDateString = String.localeDate(from: event.endDateString, .zhHantTW)
        
        switch event.startDate {
        case ..<Date.startOfTomorrowLocalTime():
            startString = "今天"
        case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
            startString = "明天"
        default:
            startString = startDateString.date
        }
        
        switch event.endDate {
        case ..<Date.startOfTomorrowLocalTime():
            endString = "今天"
        case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
            endString = "明天"
        default:
            endString = endDateString.date
        }
        
        
        if startDateString.date == endDateString.date {
            finalDateString = "\(startString) (\(startDateString.dayOfWeek ))"
        } else {
            finalDateString = "\(startString)(\(startDateString.dayOfWeek )) - \(endString)(\(endDateString.dayOfWeek ))"
        }
        
        
        self.dateString = finalDateString
        
        // MARK: - Title
        let titleString = "\(event.emojiTitle ?? "") \(event.title)"
        self.title = titleString
        
        
        
        
        
        self.imageUrlString = event.imageUrlString.first
        self.location = event.location.name
        self.tag = event.tags
        self.headcount = event.headcount
        self.participants = []
        self.peopleCount = (male:maleCount, female:femaleCount)
        
        
        
        self.emojiString = event.emojiTitle
        self.intro = event.introduction
        self.organiser = event.organisers.first
        
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        self.isOrganiser = self.organiser?.username == username
        
        self.isJoined = event.participants.values.contains(where: {return $0.username == username
        })
        
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? PostViewModel else { return false }
        return event.id == other.event.id
    }
    
    // Additional properties and methods for the event view model
}


