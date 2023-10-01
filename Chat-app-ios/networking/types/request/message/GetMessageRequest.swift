//
//  GetMessageRequest.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

struct GetMessageReq : Encodable {
    let id : UInt
    let message_type : UInt
    let friend_id : UInt
}
