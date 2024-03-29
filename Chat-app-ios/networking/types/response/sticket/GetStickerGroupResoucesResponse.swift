//
//  GetStickerGroupResponse.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import Foundation
struct GetStickerGroupResourcesResp : Decodable {
    let code : UInt
    let sticker_id : String
    let resources_path : [String]
    
    var stickerUUID : UUID {
        return UUID(uuidString: self.sticker_id)!
    }
}
