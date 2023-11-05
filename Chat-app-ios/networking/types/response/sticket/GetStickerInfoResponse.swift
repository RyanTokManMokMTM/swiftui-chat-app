//
//  GetStickerInfoResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/11/2023.
//

import Foundation

struct GetStickerInfoResp : Decodable {
    let code : UInt
    let sticker_info : StickerInfo
}
