//
//  AuthManager.swift
//  gathering
//
//  Created by Jason Chau on 2023-01-13.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()

    private init (){}

    let auth:Auth = {
        let auth = Auth.auth()
        
//        auth.useEmulator(withHost: "localhost", port: 9099)
        
        return auth
    }()
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    
    // MARK: - Login/Signup
    public func signUp(username:String,email:String, password:String, completion: @escaping (User?) -> Void) {
        
        let newUser = User(
            username: username,
            email: email,
            name: nil,
            profileUrlString: nil,
            gender: genderType.male.rawValue,
            fcmToken: CustomNotificationManager.fcmToken
        )
        
        
        DatabaseManager.shared.findUserWithUsername(with: username) { user in
            guard user == nil else {
                completion(nil)
                return}
            self.auth.createUser(withEmail: email, password: password) { result, error in
                guard error == nil, result != nil else {
                    completion(nil)
                    return
                }
                DatabaseManager.shared.createUserProfile(newUser: newUser) { success in
                    guard success else {
                        completion(nil)
                        return
                    }
                    ChatMessageManager.shared.connectToChatServer(true)
                    RelationshipManager.shared.observeFirebaseRelationshipsChangesIntoRealm()
                    NotificationCenter.default.post(name: Notification.Name("userStateRefreshed"), object: nil)
                    completion(newUser)
                }
            }
        }
    }
    
    public func logIn(email:String, password:String, completion: @escaping (User?) -> Void){
        
        auth.signIn(withEmail: email, password: password) { result, error in
            guard error == nil, result != nil else {
                completion(nil)
                return}
            
            DatabaseManager.shared.findUserWithEmail(with: email) { user in
                guard let user = user else {
                    completion(nil)
                    return}
                
                DefaultsManager.shared.updateUserProfile(with: user)
                ChatMessageManager.shared.connectToChatServer(true)
                RelationshipManager.shared.observeFirebaseRelationshipsChangesIntoRealm()
                DatabaseManager.shared.updateFcmTokenToServer()
                NotificationCenter.default.post(name: Notification.Name("userStateRefreshed"), object: nil)
                completion(user)
            }
        }
    }

    public func signOut(completion: ((Bool) -> Void)? = nil){
        do {
            try auth.signOut()
            ChatMessageManager.shared.disconnectFromChatServer()
            RealmManager.shared.clearRealmDatabase()
            DefaultsManager.shared.resetUserProfile()
            NotificationCenter.default.post(name: Notification.Name("userStateRefreshed"), object: nil)
            completion?(true)
        }catch{
            print(error)
            completion?(false)
        }
    }
    
    public func deleteAccount(password: String, completion: @escaping ((Bool) -> Void)) {
        if let user = auth.currentUser {
            // Reauthenticate user to verify password
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
            
            user.reauthenticate(with: credential) { result, error in
                if let error = error {
                    print("Error reauthenticating user: \(error)")
                    completion(false)
                } else {
                    
                    DatabaseManager.shared.deleteUserProfile(userEmail: user.email!) { success in
                        if success {
                            
                            user.delete { error in
                                if let error = error {
                                    print("Error deleting user account: \(error)")
                                    completion(false)
                                } else {
                                    
                                    NotificationCenter.default.post(name: Notification.Name("userStateRefreshed"), object: nil)

                                    RealmManager.shared.clearRealmDatabase()
                                    DefaultsManager.shared.resetUserProfile()
                                    completion(true)
                                }
                            }
                            
                        } else {
                            completion(false)
                        }
                    }
                }
            }
        } else {
            completion(false)
        }
    }
    
}
