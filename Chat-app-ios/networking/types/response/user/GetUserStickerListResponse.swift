//
//  GetUserStickerListResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 4/11/2023.
//

import Foundation

struct GetUserStickerListResp : Decodable {
    let code : UInt
    let stickers : [StickerInfo]
}
