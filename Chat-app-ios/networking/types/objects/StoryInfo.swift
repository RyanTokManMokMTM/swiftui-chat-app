//
//  storyInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct StoryInfo : Identifiable {
    let id : UInt
    let uuid : String
    let media_url : String
    let create_at : UInt
    var is_liked : Bool
    let story_seen_list : [StorySeenUserBasicInfo]?
    
    var MediaURL : URL {
        return URL(string: RESOURCES_HOST + self.media_url)!
    }
                    
    var CreatedTime : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.create_at))
    }
}
