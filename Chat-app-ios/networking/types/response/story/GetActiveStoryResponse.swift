//
//  GetActiveStoryResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetActiveStoryResp : Decodable {
    let code : UInt
    let active_stories : [FriendStory]
}
