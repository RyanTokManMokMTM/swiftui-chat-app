//
//  GetFriendInfoResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetFriendInfoResp : Decodable {
    let code : UInt
    let friend_info  : FriendInfo
}
