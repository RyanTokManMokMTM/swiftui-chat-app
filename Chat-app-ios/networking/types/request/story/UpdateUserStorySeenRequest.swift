//
//  UpdateUserStorySeenRequest.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct UpdateUserStorySeenReq : Encodable {
    let friend_id : UInt
    let story_id : UInt
}
