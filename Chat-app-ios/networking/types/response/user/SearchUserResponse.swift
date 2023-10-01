//
//  SearchUserResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct SearchUserResp : Decodable{
    let code : UInt
    let results : [SearchUserResult]?
}
