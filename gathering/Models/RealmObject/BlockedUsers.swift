//
//  BlockedUsers.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-03-26.
//

import Foundation
import RealmSwift


class BlockedUsers:Object {
    @Persisted var blockedUserList = List<String>()
}


