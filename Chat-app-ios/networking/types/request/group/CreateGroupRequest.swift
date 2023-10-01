//
//  CreateGroupRequest.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

struct CreateGroupReq : Encodable {
    let group_name : String
    let members : [UInt]
    let avatar : String
}
