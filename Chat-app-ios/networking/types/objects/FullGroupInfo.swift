//
//  FullGroupInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct FullGroupInfo : Decodable {
    let id : UInt
    let uuid : String
    var name : String
    var avatar : String
    let members : UInt
    let created_at : UInt
    var desc : String
    var is_joined : Bool
    let is_owner : Bool
    let created_by : String
    
    var AvatarURL : URL {
        return URL(string:RESOURCES_HOST + self.avatar)!
    }
    
    var CreatedAt : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.created_at))
    }
}
