//
//  SearchUserResultReponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct SearchUserResult : Decodable{
    let user_info : UserProfile
    var is_friend : Bool
}
