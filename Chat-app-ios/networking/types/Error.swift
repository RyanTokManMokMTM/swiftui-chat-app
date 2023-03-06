//
//  Error.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import Foundation

struct ErrorResp : Decodable, LocalizedError{
    let code : UInt
    let message : String
    
    var errorDescription: String? {
        return message
    }
}
