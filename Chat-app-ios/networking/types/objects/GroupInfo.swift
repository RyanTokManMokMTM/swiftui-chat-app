//
//  GroupInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GroupInfo : Decodable,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    let created_at : UInt
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }
    
    var CreatedAt : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.created_at))
    }
}
