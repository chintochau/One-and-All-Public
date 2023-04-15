//
//  EventMainViewModel.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-18.
//

import UIKit

struct OldEventViewModel {
    let owner:User?
    let event:Event
    let image:UIImage?
    let title:String
    let date:(
        title:String,
        subTitle:String
    )
    let location :(
        area:String,
        address:String
    )
    let about:String 
    
    let dateString:String
}


extension OldEventViewModel {
    
    init?(with event:Event, image:UIImage?) {
        guard  let startDate = DateFormatter.formatter.date(from: event.startDateString),
               let endDate = DateFormatter.formatter.date(from: event.endDateString) else {return nil}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // output format
        let startTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        var timeInterval = "\(startTime) - \(endTime)"
        
        if startTime == endTime {
            timeInterval = "\(startTime)"
        }
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: startDate)
        
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
            startString = startDateString.date ?? ""
        }
        
        switch event.endDate {
        case ..<Date.startOfTomorrowLocalTime():
            endString = "今天"
        case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
            endString = "明天"
        default:
            endString = endDateString.date ?? ""
        }
        
        
        if startDateString.date == endDateString.date {
            finalDateString = "\(startString) (\(startDateString.dayOfWeek ?? ""))"
        } else {
            finalDateString = "\(startString)(\(startDateString.dayOfWeek ?? "")) - \(endString)(\(endDateString.dayOfWeek ?? ""))"
        }
        
        
        self.dateString = finalDateString
        
        
        
        self.event = event
        self.image = image
        self.title = event.title
        self.date = (title:date , subTitle: timeInterval)
        self.location = (area: event.location.name, address: event.location.address ?? "")
        
        self.about = event.introduction ?? ""
        self.owner = event.organisers.first
        
        
        
    }
    
}
