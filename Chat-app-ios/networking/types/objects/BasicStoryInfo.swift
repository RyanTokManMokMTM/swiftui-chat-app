//
//  BasicStoryInfo.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/11/2023.
//

import Foundation
struct BasicStoryInfo : Identifiable,Decodable {
    let story_id : UInt
    let story_uuid : String
    let media_url : String

    var MediaURL : URL {
        return URL(string: RESOURCES_HOST + self.media_url)!
    }
    
    var id : UInt {
        return story_id
    }

}
