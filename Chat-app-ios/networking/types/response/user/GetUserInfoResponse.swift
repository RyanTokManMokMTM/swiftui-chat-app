//
//  GetUserInfoResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetUserInfoResp : Decodable{
    let code : UInt
    let uuid : String
    let name : String
    let email : String
    let avatar : String
    let cover : String
}
