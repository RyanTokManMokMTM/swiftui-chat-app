//
//  FriendInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct FriendInfo : Decodable {
    let id : UInt
    let uuid : String
    var name : String
    var avatar : String

    var UserUUID : UUID {
        return UUID(uuidString: self.uuid)!
    }
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST  + self.avatar)!
    }

}
