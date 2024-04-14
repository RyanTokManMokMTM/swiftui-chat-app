//
//  request.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import Foundation

struct SFUConnectSessionReq : Encodable {
    let session_id : String
    let SDPType   :  String
}

struct SFUGetSessionProducerReq : Encodable {
    let  session_id : String
}

struct SFUConsumeProducerReq : Encodable {
    let session_id : String
    let producer_id : String
    let SDPType :     String
}

// No need to response back to the user
struct SFUSendIceCandindateReq : Codable {
    let session_id  :  String
    let is_producer :  Bool
    let client_id   :  String
    let ice_candidate_type : String
}

struct SFUCloseConnectionReq : Encodable {
    let session_id : String
}


struct SFUProducerMediaStatus : Codable {
    let session_id : String
    let client_id : String
    let media_type : String
    let is_on : Bool
}
