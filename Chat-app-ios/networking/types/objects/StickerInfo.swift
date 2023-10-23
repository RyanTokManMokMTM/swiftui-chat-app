//
//  StickerInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import Foundation
struct StickerInfo : Decodable,Identifiable,Hashable{
    var sticker_id : String
    var sticker_name : String
    var sticker_thum : String
    
    var thumURL : URL{
        return URL(string: RESOURCES_HOST + "/sticker/" + self.sticker_thum)!
    }
    
    var id : String {
        sticker_id
    }
}
