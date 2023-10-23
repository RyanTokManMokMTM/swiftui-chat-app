//
//  GetStickerGroupListResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import Foundation
struct GetStickerGroupListResp :Decodable {
    let code : UInt
    let stickers : [StickerInfo]
    
}
