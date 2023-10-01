//
//  FriendStory.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct FriendStory : Decodable,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    var is_seen : Bool
    let latest_story_time_stamp : UInt
//    var stories_ids : [UInt]
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }
}
