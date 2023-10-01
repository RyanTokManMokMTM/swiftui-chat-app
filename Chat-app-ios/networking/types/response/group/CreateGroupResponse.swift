//
//  CreateGroupResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct CreateGroupResp : Decodable {
    let code : UInt
    let group_uuid : String
    let grou_avatar : String
}
