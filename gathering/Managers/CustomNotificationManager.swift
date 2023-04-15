//
//  NotificationManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-14.
//

import UIKit
import FirebaseFirestore
import FirebaseMessaging

struct CustomNotificationManager {
    static let shared = CustomNotificationManager()
    
    static let fcmToken = Messaging.messaging().fcmToken
    
    let database:Firestore = {
        let database = Firestore.firestore()
        return database
    }()
    
    
    
    func requestForNotification(){
        
        // user notifications auth
        // all of this works for iOS 10+
        let options:UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Failed to request Auth:", error)
                return
            }
            
            if granted {
                print("Auth Granted")
            } else {
                print("Auth denied")
            }
        }
        
    }
    
    func fetchNotifications(lastNotificationDate:Double, completion:@escaping ([GANotification]) -> Void){
        guard let user = DefaultsManager.shared.getCurrentUser() else {return}
        
        let monthStartDate = GANotification.startDateString
        let monthEndDate = GANotification.endDateString
        
        let ref = database.collection("notifications/\(user.username)/notifications")
            .order(by: monthEndDate, descending: false)
            .whereField( monthEndDate, isGreaterThan: lastNotificationDate)
            .limit(to: 1)
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("No data fetched")
                completion([])
                return
            }
            
            var notifications = [GANotification]()
            
            for document in documents {
                if let data = document.data() as? [String: Any] {
                    for (key, value) in data {
                        if key != monthStartDate && key != monthEndDate {
                            if let value = value as? [String: Any],
                               let notification = GANotification(with: value){
                                notifications.append(notification)
                            }
                        }
                    }
                }
            }
            completion(notifications)
        }
    }
    
    func sendNotificationToUser(username:String, notification:GANotification){
        
        guard let notificationData = notification.asDictionary() else {return}
        
        let ref = database.collection("notifications/\(username)/notifications").document(Date().yearMonthStringUTC())
        
        ref.setData([
            GANotification.startDateString: Date().startOfMonthTimestampUTC(),
            GANotification.endDateString: Date().startOfNextMonthTimestampUTC()-1,
            notification.id: notificationData
        ], merge: true)
        
        
    }
}
