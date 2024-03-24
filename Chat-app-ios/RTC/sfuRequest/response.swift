//
//  response.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import Foundation
struct SfuNewProducerResp : Decodable {
    let session_id : String
    let producer_info : SfuProducerUserInfo
}

struct SFUConnectSessionResp : Decodable {
    let session_id : String
    let producer_id : String
    let session_producers : [SfuProducerUserInfo]
}

struct SfuProducerUserInfo : Decodable {
    let producer_user_id     :  String
    let producer_user_name   : String
    let producer_user_avatar : String
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST  + self.producer_user_avatar)!
    }
}

struct SfuConnectSessionResp : Decodable {
    let session_id : String
    let SDPType : String
}

struct SfuGetSessionProducerResp : Decodable {
    let session_id   : String
    let producer_list : [String]
}

struct SFUConsumeProducerResp : Decodable {
    let session_id  : String
    let producer_id : String
    let SDPType  : String
}

struct SFUCloseConnectionResp : Decodable {
    let session_id : String
    let producer_id : String
}
