//
//  IsUserStickerExistResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 4/11/2023.
//

import Foundation

struct IsUserStickerExistResp : Decodable {
    let code : UInt
    let is_exist : Bool
}
