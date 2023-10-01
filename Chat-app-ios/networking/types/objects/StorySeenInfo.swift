//
//  StorySeenInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 1/10/2023.
//

import Foundation
struct StorySeenInfo : Decodable,Identifiable{
    let id : UInt
    let uuid : String
    let name : String
    let avatar : String
    let is_liked : Bool
    let created_at : UInt
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }

}
