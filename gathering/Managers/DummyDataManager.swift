//
//  DummyDataManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-22.
//

import UIKit
import Firebase
import FirebaseFirestore

struct DummyDataManager {
    static let shared = DummyDataManager()

    func createDemoUsers() {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        
        let commonNames = ["Jack", "Emily", "Harry", "Olivia", "Charlie", "Sophie", "Thomas", "Amelia", "James", "Emma", "William", "Ava", "George", "Mia", "Benjamin", "Isabella", "Jacob", "Charlotte", "Ethan", "Grace"]
        let interests = ["旅遊", "美食", "運動", "電影", "閱讀", "音樂", "科技", "藝術", "手作", "時尚"]
        
        for i in 1...20 {
            let randomName = commonNames.randomElement()!
            let username = "user\(i)"
            let numInterests = Int.random(in: 1...3)
            let randomInterests = (0..<numInterests).map { _ in interests.randomElement()! }
            
            let user = User(
                username: username, email: nil, name: randomName, profileUrlString: "https://picsum.photos/400/300?random=\(i)", gender: nil, birthday: nil, rating: nil, fcmToken: nil, chatToken: nil, interests: randomInterests, contacts: nil
            )
            
            guard let userDict = user.asDictionary() else {return}
            
            usersRef.document(username).setData(userDict) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Document added with ID: \(username)")
                }
            }
        }
    }

    
    func generateDummyEvents() {
        
        for i in 1...20 {
            // Generate a unique ID for the event
            let eventId = UUID().uuidString
            
            let randomValue = Int.random(in: 0...4)
            let emoji: String?
            
            switch randomValue {
            case 0:
                emoji = "😀"
            case 1:
                emoji = "🤔"
            case 2:
                emoji = "😍"
            case 3:
                emoji = "😈"
            case 4:
                emoji = "🤡"
            default:
                emoji = nil
            }
            
            // Generate a random introduction for the event
            let introduction = "Join us for the \(HomeCategoryType.allCases.randomElement()!.rawValue) event of the year! This is a great opportunity to meet new people, have fun, and enjoy some amazing activities. Our expert organizers have put together a fantastic lineup of events that will keep you engaged and entertained all day long. Whether you're a seasoned pro or a beginner, there's something for everyone at this event. So come on out and join us for a day of fun and excitement! "
            
            
            
            var organisers = [User]()
            var participants = [String: Participant]()
            var imageUrlStrings = [String]()
            
            for j in 1...20 {
                // Generate a user for the participant
                let user = User(
                    username: "participant\(j)_event\(i)",
                    email: "participant\(j)_event\(i)@example.com",
                    name: "Participant \(j)",
                    profileUrlString: nil,
                    gender: j % 2 == 0 ? "male" : "female"
                )
                
                // Create a participant for the user
                let participant = Participant(with: user)
                
                // Add the user to the organisers list for the first event
                if j == 1 {
                    organisers.append(user)
                }
                
                // Add the participant to the participants list
                participants[user.username] = participant
            }
            
            // Generate an image URL for the event
            imageUrlStrings.append("https://picsum.photos/400/300?random=\(i)")
            
            // Generate dummy data for the event
            var comments = [Comment]()
            for k in 1...10 {
                let comment = Comment(
                    sender: "participant\(k)_event\(i)",
                    message: "This event sounds amazing! Can't wait to join!",
                    timestamp: Date(timeIntervalSinceNow: -TimeInterval(i * 86400/10)).timeIntervalSince1970)
                comments.append(comment)
            }
            
            // Generate dummy data for the event
            let event = Event(
                id: eventId,
                emojiTitle: emoji,
                title: "Event \(i)",
                organisers: organisers,
                imageUrlString: imageUrlStrings,
                startDateTimestamp: Date(timeIntervalSinceNow: TimeInterval(i * 86400/10)).timeIntervalSince1970,
                endDateTimestamp: Date(timeIntervalSinceNow: TimeInterval((i+1) * 86400/10)).timeIntervalSince1970,
                location: Location(name: "Location \(i)", address: "Address \(i)", latitude: Double(i), longitude: Double(i+1)),
                presetTags: [],
                introduction: introduction,
                participants: participants,
                comments: comments,
                headcount: Headcount(isGenderSpecific: i%3 == 0 ? true : false, min: 0, max: 100, mMin: 0, mMax: 50, fMin: 0, fMax: 50),
                ownerFcmToken: "dUeVDWDOEk0yh8z1I4N8X6:APA91bGiNIm7sYjL1u8Q6r0NGpFasVpqkipdQs1b8HxhNeZliZ0fN6y5gQ9zVNXgHYA1OZ1UXv9hqgGeIUe-nRApvD2YSdYo_kvx2LLOa_dh0eqXh57ljEd3orUmDr-WFpwxeBQkCWiW",
                eventStatus: i%3 == 0 ? .grouping : .confirmed
            )
            
            
            
            // Upload the event data to Firestore
            DatabaseManager.shared.createEvent(with: event) { success in
                print("Event created with event ID: \(event.id)")
            }
        }
    }

    
    let database = Firestore.firestore()
    
    func createNotificationForEachUsers(){
        
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {return}
            documents.forEach({
                guard let user = User(with: $0.data()) else {return}
                
                let ref = database.document("notifications/\(user.username)/notifications/\(Date().yearMonthStringUTC())")
                
                ref.setData([
                    GANotification.startDateString: Date().startOfMonthTimestampUTC(),
                    GANotification.endDateString: Date().startOfNextMonthTimestampUTC()-1,
                    "fcmToken" : user.fcmToken ?? ""
                ], merge: true)
                
                
            })
        }
        
        
    }
    
    
}

extension String {
    func repeating(_ count: Int) -> String {
        var result = ""
        for _ in 0..<count {
            result += self
        }
        return result
    }
}
