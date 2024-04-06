//
//  config.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/5/2023.
//

import Foundation

fileprivate let defaultIceServer = [
    "stun:stun.l.google.com:19302",
//    "stun:stun1.l.google.com:19302",
//    "stun:stun2.l.google.com:19302",
//    "stun:stun3.l.google.com:19302",
//    "stun:stun4.l.google.com:19302"
]

fileprivate let defaultSignalServer = "http://127.0.0.1:8081/ws"

struct Config {
    let singalServer : String
    let IceServers : [String]
    
    static let `default` = Config(singalServer: defaultSignalServer, IceServers: defaultIceServer)
}
