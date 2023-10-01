//
//  GetMessageResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetMessageResp : Decodable {
    let code : UInt
    let message : [MessageUser]
}
