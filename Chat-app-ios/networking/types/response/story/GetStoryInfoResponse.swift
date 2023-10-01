//
//  GetStoryInfoResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetStoryInfoResp : Decodable {
    let code : UInt
    let story_id : UInt
    let media_url : String
    let is_liked : Bool
    let create_at : UInt
    let story_seen_list : [StorySeenUserBasicInfo]?
}
