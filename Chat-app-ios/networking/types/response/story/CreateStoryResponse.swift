//
//  CreateStoryResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

//MARK: STORIES
struct CreateStoryResp : Decodable {
    let code : UInt
    let story_id : uint
}
