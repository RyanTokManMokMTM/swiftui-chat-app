//
//  GroupMemberInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

struct GroupMemberInfo : Decodable ,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
//    let email : String
    let avatar : String
    let is_group_lead : Bool
    
    var AvatarURL : URL {
        return URL(string:RESOURCES_HOST + self.avatar)!
    }
}
