//
//  Event.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-11.
//

import Foundation
import SwiftDate


struct Event:Codable {
    let id: String
    let emojiTitle:String?
    let title:String
    let organisers:[User]
    let imageUrlString:[String]
    let startDateTimestamp:Double
    let endDateTimestamp:Double
    let location:Location
    let presetTags:[TagType]
    let introduction:String?
    let participants:[String:Participant]
    let comments:[Comment]
    let headcount:Headcount
    let ownerFcmToken:String?
    let eventStatus:EventStatus
    
    /// "events/{YearWeek}"
    var referencePath:String? = nil
    /// "{YearMonth}"
    var referencePathForUser:String? = nil
    
    
    var autoApprove:Bool = true
    var allowWaitList:Bool = true
}


extension Event {
    // MARK: - Participants related
    var allParticipants:[Participant] {
        participants.compactMap{($1)}
    }
    
    var confirmedParticipants:[Participant] {
        allParticipants.compactMap({
            ($0.joinStatus == .going || $0.joinStatus == .host)  ? $0 : nil
        })
    }
    
    var confirmedFriends:[Participant] {
        RelationshipManager.shared.getFriendsFromParticipants(from: confirmedParticipants)
    }
    
}

extension Event {
    // MARK: - Computed properties
    
    var tags:[Tag] {
        var displayTags = [Tag]()
        
        // add preset tags
//        for tagType in presetTags {
//            displayTags.append(Tag(type: tagType))
//        }
        
        
        if headcount.isGenderSpecific {
            let minMale: Int? = headcount.mMin ?? 0 > 0 ? headcount.mMin : nil
            let minFemale: Int? = headcount.fMin ?? 0 > 0 ? headcount.fMin : nil
            if minMale != nil || minFemale != nil {
                displayTags.append(Tag(type: .peoplCount,minMale: minMale,minFemale: minFemale,genderSpecific: headcount.isGenderSpecific))
            }
            
        } else {
            let minHeadcount:Int? = headcount.min ?? 0 > 0 ? headcount.min : nil
            
            if minHeadcount != nil {
                displayTags.append(Tag(type: .peoplCount,minHeadcount: minHeadcount,genderSpecific: headcount.isGenderSpecific))
            }
            
        }
        
        if displayTags.isEmpty {
            switch eventStatus {
            case .grouping:
                displayTags.append(Tag(type: .grouping))
            case .confirmed:
                displayTags.append(Tag(type: .grouped))
            default: break
            }
        }
        
        if isJoined {
            displayTags.append(Tag(type: .joined))
        }
        
        return displayTags
        
    }
    
    var isJoined:Bool {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return false}
        return participants.values.contains(where: {return $0.username == username
        })
    }
    
    var startDate:Date {
        return Date(timeIntervalSince1970: startDateTimestamp)
    }
    var endDate:Date {
        return Date(timeIntervalSince1970: endDateTimestamp)
    }
    
    
    var startDateString:String {
        return String.date(from: startDate) ?? "Now"
    }
    
    var endDateString:String {
        return String.date(from: endDate) ?? "Now"
    }
    
    
}

extension Event {
    // MARK: - Public functions
    
    static let interests = [
        "滑雪 ",
        "運動 ⚽️",
        "音樂 🎵",
        "藝術 🎨",
        "烹飪 🍳",
        "旅遊 🌎",
        "攝影 📷",
        "閱讀 📚",
        "寫作 ✍️",
        "編程 💻",
        "游泳 🏊‍♂️",
        "健行 🥾",
        "跳舞 💃",
        "唱歌 🎤",
        "遊戲 🎮",
        "電影 🎥",
        "電視節目 📺",
        "時尚 👗",
        "美容 💄",
        "健身 🏋️‍♀️",
        "瑜伽 🧘‍♀️",
        "冥想 🧘‍♂️",
        "投資 💰",
        "股票 📈",
        "加密貨幣 💱",
        "政治 🗳️",
        "歷史 📜",
        "科學 🧪",
        "科技 🖥️",
        "商業 💼",
        "市場行銷 📈",
        "廣告 📣",
        "設計 🎨",
        "建築 🏰",
        "旅行 ✈️",
        "語言 🗣️",
        "文化 🎎",
        "美食 🍜",
        "葡萄酒 🍷",
        "啤酒 🍺",
        "咖啡 ☕️",
        "茶 🍵",
        "園藝 🌻",
        "寵物 🐶",
        "志願服務 🙏",
        "慈善 💝",
        "慈善事業 🤝"
    ]
    
    
    
    public func headCountString () -> (total:String,male:String,female:String, isMaleFull:Bool, isFemaleFull:Bool,isFull:Bool) {
        var maleCount = 0
        var femaleCount = 0
        
        self.confirmedParticipants.forEach { participant in
            switch participant.gender {
            case genderType.male.rawValue:
                maleCount += 1
            case genderType.female.rawValue:
                femaleCount += 1
            default:
                print("case not handled")
            }
        }
        
        let headcount = self.headcount

        let female:String = {
            switch headcount.fMax {
            case nil:
                return ""
            case 0:
                return "hide"
            case let x where x! > 0:
                return "/\(x!)"
            default:
                fatalError()
            }
        }()

        let male:String = {
            switch headcount.mMax {
            case nil:
                return ""
            case 0:
                return "hide"
            case let x where x! > 0:
                return "/\(x!)"
            default:
                fatalError()
            }
        }()
        
        var maleString = ""
        var femaleString = ""
        var totalString = ""
        
        let isMaleFull = maleCount >= headcount.mMax ?? 9999
        let isFemaleFull = femaleCount >= headcount.fMax ?? 9999
        let isFull = femaleCount >= headcount.max ?? 9999
        
        
        
        if headcount.mMax == 0 {
            maleString = "-"
        }else {
            maleString = "\(maleCount)\(male)"
        }
        
        
        if headcount.fMax == 0 {
            femaleString = "-"
        }else {
            femaleString = "\(femaleCount)\(female)"
        }
        
        if headcount.isGenderSpecific {
            let totalCap:Int = (headcount.mMax ?? 0) + (headcount.fMax ?? 0)
            let totalCapString:String = totalCap > 0 ? "/\(totalCap)" : ""
            totalString = "\(maleCount + femaleCount)\(totalCapString)"
        }else {
            totalString = "\(maleCount + femaleCount)" + (headcount.max == nil ? "" : "/\(String(headcount.max!))")
        }
        
        return (totalString,maleString,femaleString,isMaleFull,isFemaleFull,isFull)
    }
    
    public func canJoinEvent() -> Bool {
        // Calculate the number of male and female participants
        var numMales = 0
        var numFemales = 0
        for participant in confirmedParticipants {
            if participant.gender == "male" {
                numMales += 1
            } else if participant.gender == "female" {
                numFemales += 1
            }
        }

        guard let gender = UserDefaults.standard.string(forKey: "gender") else {return false}
                
        // Check if the new joiner can join based on gender-specific requirements
        if headcount.isGenderSpecific {
            if gender == "male" {
                if let mMax = headcount.mMax, numMales >= mMax {
                    return false
                }
            } else if gender == "female" {
                if let fMax = headcount.fMax, numFemales >= fMax {
                    return false
                }
            }
        } else {
            let totalParticipants = numMales + numFemales
            if let max = headcount.max, totalParticipants >= max {
                return false
            }
        }

        // If all checks pass, the new joiner can join the event
        return true
    }

    
    public func getDateStringForCell () -> String {
        // MARK: - Date
        var finalDateString:String = ""
        var startString:String = ""
        var endString:String = ""
        let startDateString = String.localeDate(from: startDateString, .zhHantTW)
        let endDateString = String.localeDate(from: endDateString, .zhHantTW)
        
        
        switch startDate {
        case ..<Date.startOfTodayLocalTime():
            startString = startDateString.relative
        case ..<Date.startOfTomorrowLocalTime():
            startString = "今天"
        case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
            startString = "明天"
        default:
            startString = startDateString.date
        }
        
        switch endDate {
        case ..<Date.startOfTodayLocalTime():
            endString = endDateString.relative
        case ..<Date.startOfTomorrowLocalTime():
            endString = "今天"
        case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
            endString = "明天"
        default:
            endString = endDateString.date
        }
        
        if startDateString == endDateString {
            // Same Day same time
            finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time)"
            
        }else if startDateString.date == endDateString.date {
            // same day different time
            finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time) - \(endDateString.time)"
            
        }else {
            
            finalDateString = "\(startDateString.dayOfWeek),\(startString) - \(endDateString.dayOfWeek),\(endString)"
        }
        
        return finalDateString
    }
    
    
    public func getDateDetailString () -> String {
        // MARK: - Date
        var finalDateString:String = ""
        var startString:String = ""
        var endString:String = ""
        let startDateString = String.localeDate(from: startDateString, .zhHantTW)
        let endDateString = String.localeDate(from: endDateString, .zhHantTW)
        
        
        switch startDate {
        default:
            startString = startDateString.date
        }
        
        switch endDate {
        default:
            endString = endDateString.date
        }
        
        if startDateString == endDateString {
            // Same Day same time
            finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time)"
            
        }else if startDateString.date == endDateString.date {
            // same day different time
            finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time) - \(endDateString.time)"
            
        }else {
            
            finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time)\n - \(endDateString.dayOfWeek),\(endString) \(endDateString.time)"
        }
        
        return finalDateString
    }
    
    
    public func getTimeString () -> String{
        // MARK: - Time
        let startDateString = String.localeDate(from: startDateString, .zhHantTW)
        let endDateString = String.localeDate(from: endDateString, .zhHantTW)
        
        if startDateString.time == endDateString.time {
            return startDateString.time
        }else {
            return "\(startDateString.time) - \(endDateString.time)"
        }
    }
    
}

struct Headcount:Codable {
    var isGenderSpecific:Bool = false
    var min:Int? = nil
    var max:Int? = nil
    var mMin:Int? = nil
    var mMax:Int? = nil
    var fMin:Int? = nil
    var fMax:Int? = nil
    
    func isEmpty () -> Bool {
        return [min,mMin,fMin].allSatisfy({$0 == 0})
    }
    
}


enum HomeCategoryType:String,CaseIterable {
    case grouped = "已成團"
    case grouping = "組團中"
    case mentor = "導師"
    case organisation = "本地團體"
}


enum EventStatus:Int,Codable {
    case grouping
    case confirmed
    case activity
    case cancelled
}




extension Event {
    func toString (includeTime:Bool) -> String {
        let event = self
        
        
        
        let emojiString:String = {
            if let emojiString = event.emojiTitle {
                return emojiString + " "
            }else {
                return ""
            }
        }()
        
        let title:String = "\(event.title) \n"
        
        let intro:String = {
            if let intro = event.introduction {
                return "\(intro)\n"
            }else {
                return ""
            }
        }()
        
        let localeDate = String.localeDate(from: event.startDateString, .zhHantTW)
        
        let date = localeDate.date
        let dayOfWeek = localeDate.dayOfWeek
        let time = localeDate.time
        
        let dateString:String = {
            return "\n日期: \(date) (\(dayOfWeek))"
        }()
        
        let timeString:String = {
            if includeTime {
                return "\n時間: \(time)"
                
            } else {
                return ""
            }
        }()
        
        let location:String = {
            return "\n地點: " + event.location.name
        }()
        
        let address:String = {
            if let address = event.location.address {
                return ", " + address
            }
            return ""
        }()
        
        let participants:String = {
            let user = DefaultsManager.shared.getCurrentUser()
            
            let currentUsername = user?.username
            let currentName = user?.name
            
            var counter:Int = 1
        
            var namelist = "\n報名: "
            for participant in event.participants {
                namelist += "\n\(counter). " + (participant.key == currentUsername ? currentName ?? "Not Valid" : participant.key)
                counter += 1
            }
            return namelist
        }()
        
        let deekLink:String = {
            return "\n\n\(EventDeeplinkHandler.generateEventDeepLink(with: event))"
        }()
        
        
        let string = emojiString + title + intro + deekLink + dateString +  timeString + location + address + participants
        return string
    }
}
