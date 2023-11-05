//
//  GetUserStoriesResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetUserStoriesResp : Decodable {
    let code : UInt
    let stories : [BasicStoryInfo]
    let last_story_id : UInt
}
