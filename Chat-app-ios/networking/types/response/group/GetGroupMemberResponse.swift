//
//  GetGroupMemberResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetGroupMembersResp : Decodable {
    let code : UInt
    let member_list : [GroupMemberInfo]
}
