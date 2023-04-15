//
//  UserDefaultsManager.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-28.
//

import Foundation

enum UserDefaultsType:String,CaseIterable {
    case username = "username"
    case email = "email"
    case profileUrlString = "profileUrlString"
    case gender = "gender"
    case name = "name"
    case user = "user"
    case favEvent = "favouriteEvents"
    case favUser = "favouriteUsers"
    case chatToken = "chatToken"
    case region = "region"
}


final class DefaultsManager {
    static let shared = DefaultsManager()
    
    
    
    // MARK: - User
    public func updateUserProfile(with user:User){
        UserDefaults.standard.set(user.username, forKey: "username")
        UserDefaults.standard.set(user.email, forKey: "email")
        UserDefaults.standard.set(user.profileUrlString, forKey: "profileUrlString")
        UserDefaults.standard.set(user.gender, forKey: "gender")
        UserDefaults.standard.set(user.name, forKey: "name")
        UserDefaults.standard.set(user.chatToken, forKey: "chatToken")
        if let user = user.asDictionary() {
            UserDefaults.standard.set(user, forKey: "user")
        }
    }
    
    public func updateUserProfileFromServer(username:String) {
        
        DatabaseManager.shared.findUserWithUsername(with: username) {[weak self] user in
            guard let user = user else {return}
            self?.updateUserProfile(with: user)
        }
        
    }
    
    public func resetUserProfile(){
        UserDefaultsType.allCases.forEach({
            UserDefaults.standard.set(nil, forKey: $0.rawValue)
        })
        
    }
    
    public func printAllUserdefaults(){
        UserDefaultsType.allCases.forEach({
            switch $0 {
            case .user:
                    print(getCurrentUser() ?? "Not Set" )
            default:
                print("\($0.rawValue): \(UserDefaults.standard.string(forKey: $0.rawValue) ?? "Not Set")")
            }
        })
    }
    
    public func getCurrentUser() -> User? {
        
        guard let user = UserDefaults.standard.object(forKey: "user") as? [String : Any] else {
            
            return nil
            
        }
        
        return User(with: user)
    }
    
    
    
    // MARK: - Fav Events
    public func getFavouritedEvents() -> [String] {
        if let array = UserDefaults.standard.array(forKey: UserDefaultsType.favEvent.rawValue) as? [String] {
            return array
        }
        return []
    }
    
    public func saveFavouritedEvents(eventID:String){
        var array = getFavouritedEvents()
        array.append(eventID)
        UserDefaults.standard.set(array, forKey: UserDefaultsType.favEvent.rawValue)
    }
    public func removeFromFavouritedEvents(eventID:String){
        var array = getFavouritedEvents()
        
        
        if let index = array.firstIndex(of: eventID) {
            array.remove(at: index)
            UserDefaults.standard.set(array, forKey: UserDefaultsType.favEvent.rawValue)
            
            
        }else{
            
            UserDefaults.standard.set(array, forKey: UserDefaultsType.favEvent.rawValue)
        }
        
    }
    public func isEventFavourited(eventID:String) -> Bool {
        let array = getFavouritedEvents()
        if let _ = array.firstIndex(of: eventID) {
            return true
        }else {
            return false
        }
    }
    
    // MARK: - Follows
    public func getFavouritedUsers() -> [String] {
        if let array = UserDefaults.standard.array(forKey: UserDefaultsType.favUser.rawValue) as? [String] {
            return array
        }
        return []
    }
    
    public func toFollowUser(userID:String){
        var array = getFavouritedUsers()
        array.append(userID)
        UserDefaults.standard.set(array, forKey: UserDefaultsType.favUser.rawValue)
    }
    public func removeFromFavouritedUsers(userID:String){
        var array = getFavouritedUsers()
        
        if let index = array.firstIndex(of: userID) {
            array.remove(at: index)
            UserDefaults.standard.set(array, forKey: UserDefaultsType.favUser.rawValue)
            
        }else{
            
            UserDefaults.standard.set(array, forKey: UserDefaultsType.favUser.rawValue)
        }
        
    }
    public func isUserFavourited(userID:String) -> Bool {
        let array = getFavouritedUsers()
        if let _ = array.firstIndex(of: userID) {
            return true
        }else {
            return false
        }
    }
    
}


