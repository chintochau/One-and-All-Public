//
//  AppDelegate.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-10.
//

import UIKit
import FirebaseCore
import UserNotifications
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //        application.clearLaunchScreenCache()
        
        
        
        // Get the URL of the default Realm file
        if let defaultRealmURL = Realm.Configuration.defaultConfiguration.fileURL {
            print("Default Realm file URL: \(defaultRealmURL)")
        } else {
            print("Unable to get default Realm file URL")
        }
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        attemptRegisterForNotifications(application: application)
        return true
    }
    
    // MARK: - Handle Deek Link
    
    
    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let eventId = queryItems.first(where: { $0.name == "eventId" })?.value,
              let eventRef = queryItems.first(where: {$0.name == "Ref"})?.value
        else {
            return
        }
        // Show the event with the given ID
        let eventViewController = EventDetailViewController()
        eventViewController.configureWithID(eventID: eventId, eventReferencePath: eventRef)
        
        // Get the window instance
        guard let window = UIApplication.shared.windows.first else { return }
        
        if let mainTabBarVC = window.rootViewController as? TabBarViewController {
            mainTabBarVC.selectedIndex = 0
            if let homeNavVC = mainTabBarVC.viewControllers?.first as? UINavigationController {
                homeNavVC.pushViewController(eventViewController, animated: true)
            }
        }
        
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let eventId = userInfo["eventId"] as? String,
           let eventReference = userInfo["referencePath"] as? String {
            
            // Get the window instance
            guard let window = UIApplication.shared.windows.first else { return }
            
//            let vc = EventDetailViewController()
//            vc.configureWithID(eventID: eventId, eventReferencePath: eventReference)
            if let mainTabBarVC = window.rootViewController as? TabBarViewController {
                mainTabBarVC.selectedIndex = 0
                if let homeNavVC = mainTabBarVC.viewControllers?.first as? UINavigationController {
                    homeNavVC.presentEventDetailViewController(eventID: eventId, eventRef: eventReference)
                }
            }
        }
    }
    
    // This function can be called from any part of your app to get the window instance.
    func getWindow() -> UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window
    }
    
    
    
}


extension AppDelegate:MessagingDelegate,UNUserNotificationCenterDelegate {
    
    private func attemptRegisterForNotifications(application:UIApplication) {
        // MARK: - Firebase Notification
        let messaging = Messaging.messaging()
        messaging.delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even if the app is in the foreground
        completionHandler([.alert, .badge])
    }
    
}


public extension UIApplication {

    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
    }

}
