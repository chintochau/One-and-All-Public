//
//  SearchManager.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-16.
//

import Foundation
import AlgoliaSearchClient

struct SearchManager {
    static let shared = SearchManager()
    
    let client = SearchClient(appID: "", apiKey: "")
    
    func searchForEvents(words:String, completion:@escaping ([UserEvent]) -> Void) {
        
        let index = client.index(withName: "Events")
        
        let query = Query(words)
        
        index.search(query: query) { result in
            if case .success(let response) = result {
                let events: [UserEvent] = response.hits.compactMap { hit in
                    guard let data = hit.asDictionary(),
                    let event = UserEvent(with: data) else {
                        return nil
                    }
                    return event
                }
                completion(events)
            }
        }
    }
    
    
    
    func searchForUserss(words:String, completion:@escaping ([User]) -> Void) {
        
        let index = client.index(withName: "Users")
        
        let query = Query(words)
        
        index.search(query: query) { result in
            if case .success(let response) = result {
                let users: [User] = response.hits.compactMap { hit in
                    guard let data = hit.asDictionary(),
                    let user = User(with: data) else {
                        return nil
                    }
                    return user
                }
                completion(users)
            }
        }
    }
}
