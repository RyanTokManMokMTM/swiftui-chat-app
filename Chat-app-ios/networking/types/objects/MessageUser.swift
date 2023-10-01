//
//  MessageUser.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct MessageUser : Decodable {
    let id : UInt
    let from_id : UInt
    let to_id : UInt
    let content : String
    let content_type : UInt
    let message_type : UInt
    let create_at : UInt
}
