//
//  SignInRequest.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

struct SignInResp : Decodable {
    let code : UInt
    let token : String
    let expired_time : UInt
    let user_info : UserProfile
    
}
