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

struct SfuProducerUserInfo : Decodable {
    let producer_user_id     :  String
    let producer_user_name   : String
    let producer_user_avatar : String
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
