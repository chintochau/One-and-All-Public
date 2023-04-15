//
//  SearchResult.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-10.
//

import Foundation

enum searchResultType:String{
    case user = "user"
    case event = "Event"
}

struct SearchResult {
    let type: searchResultType
    let title:String
    let subtitle:String
}

extension SearchResult {
    init(with user:User) {
        title = user.name ?? "New User"
        subtitle = "@\(user.username)"
        type = .user
    }
    init(with event:UserEvent) {
        title = event.name
        subtitle = event.dateString
        type = .event
    }
    init(with text:String,type:searchResultType) {
        title = text
        subtitle = ""
        self.type = type
    }
}
