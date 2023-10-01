//
//  signUp.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation

struct SignUpReq : Encodable {
    let email : String
    let name : String
    let password : String
}
