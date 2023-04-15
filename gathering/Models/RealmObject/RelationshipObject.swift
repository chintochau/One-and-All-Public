//
//  RelationshipObject.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-20.
//

import UIKit
import RealmSwift

enum relationshipType:Int {
    case noRelation
    case pending
    case received
    case friend
    case blocked
}

class RelationshipObject: Object, Codable {
    @Persisted var id = ""
    @Persisted(primaryKey: true) var targetUsername:String = ""
    @Persisted var selfUsername:String = ""
    @Persisted var status:Int = 0
    @Persisted var relationshipScore:Double = 0
    @Persisted var date = Date()
    
    var targetUser: UserObject? {
        let realm  = try! Realm()
        return realm.object(ofType: UserObject.self, forPrimaryKey: targetUsername)
    }
}
