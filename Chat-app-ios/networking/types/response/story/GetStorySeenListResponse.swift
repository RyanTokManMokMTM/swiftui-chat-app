//
//  GetStorySeenListResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 1/10/2023.
//

import Foundation
struct GetStorySeenListResp : Decodable{
    let code : UInt
    let total_seen : UInt
    let seen_list : [StorySeenInfo]
}
