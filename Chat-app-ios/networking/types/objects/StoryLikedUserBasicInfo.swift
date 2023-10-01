//
//  StoryLikedUserBasicInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 1/10/2023.
//

import Foundation
struct StorySeenUserBasicInfo : Decodable,Identifiable {
    let user_id : UInt
    let avatar : String
    
    var id : UInt {
        return self.user_id
    }
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }

}
