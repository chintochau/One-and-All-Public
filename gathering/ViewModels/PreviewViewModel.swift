//
//  PreviewViewViewModel.swift
//  gathering
//
//  Created by Jason Chau on 2023-02-05.
//

import Foundation

struct PreviewViewModel{
    let event:Event
    
    var eventString:String {
        event.toString(includeTime: false)
    }
    
}
