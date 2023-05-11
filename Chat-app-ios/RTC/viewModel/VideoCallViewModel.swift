//
//  VideoCallViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/5/2023.
//

import Foundation
import WebRTC
import SwiftUI
import Combine
class VideoCallViewModel : ObservableObject {
    @Published var isConnectd : Bool = false
    @Published var isSetLoaclSDP : Bool = false
    @Published var isSetRemoteSDP : Bool = false
    @Published var localCanindate : Int = 0
    @Published var remoteCanindate : Int = 0
    @Published var connectionStatus : RTCIceConnectionState = .closed
    @Published var IsReceivedMessage : Bool = false
    @Published var receivedMessage : String = ""
    
    @Published var remoteVideoTrack : RTCVideoTrack?
    @Published var localVideoTrack : RTCVideoTrack?
    
    @Published var refershRemoteTrack : Bool = false
    @Published var refershLocalTrack : Bool = false

    
    var activeRoom : ActiveRooms?

    //MARK: Singal
    var webSocket : Websocket?
    var queue = [String]()
    var webRTCClient : WebRTCClient?
    var toUserUUID : String?
    
    
    init(){
    }
    
    func start(){
        prepare()
    }
    
    private func prepare(){
        self.webSocket = Websocket.shared
        self.webRTCClient = WebRTCClient()
        
        remoteVideoTrack = self.webRTCClient?.remoteVIdeoTrack
        localVideoTrack = self.webRTCClient?.localVideoTrack
        refershRemoteTrack = true
        refershLocalTrack = true
        
        self.webRTCClient?.delegate = self
        self.webSocket?.delegate = self

    }
    
    
    private func clear(){
        self.webSocket = nil
        self.webRTCClient = nil
        self.localVideoTrack = nil
        self.remoteVideoTrack = nil
        refershRemoteTrack = true
        refershLocalTrack = true
        
    }
    
}

extension VideoCallViewModel : WebRTCClientDelegate{
    func webRTCClient(_ client: WebRTCClient, sendData data: Data) {
        self.sendSingleMessage(data)
    }
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("receivd a local candindate!")
        guard let candinateData = candidate.JSONData() else {
            print("candindate failed")
            return
        }
        DispatchQueue.main.async {
            self.localCanindate += 1
        }

        self.sendSingleMessage(candinateData)
        //send to
    }
//
//    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCVideoTrack) {
//        print("received remote streaming data....")
//
//        DispatchQueue.main.async {
//            self.remoteVideoTrack = stream
//            self.refershRemoteTrack = true
//        }
//    }
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("received a message via data channel")
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? ("Binary \(data.count) bytes")
            self.receivedMessage = message
            self.IsReceivedMessage = true
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState){
        DispatchQueue.main.async {
            self.connectionStatus = state
        }
       
    }
}



extension VideoCallViewModel {
    func sendSingleMessage(_ message : Data) {
        guard let sdpStr = message.toJSONString else {
            return
        }
        
        let sdp = sdpStr as String

        webSocket?.sendRTCSignal(toUUID: self.toUserUUID!, sdp: sdp)
    }
    
    func processSignalingMessage(_ message: String,websocketMessage : WSMessage) -> Void {
        guard let webRTCClient = webRTCClient else { return }
        
        let signalMessage = SignalMessage.from(message: message)
        switch signalMessage {
        case .candidate(let candidate):
            print("candindate")
            webRTCClient.handleCandidateMessage(candidate,completion: { error in
                DispatchQueue.main.async {
                    self.remoteCanindate += 1
                }

            })
        case .answer(let answer):
            print("Recevie answer:") //receving answer -> offer is the remoteSDP for the receiver
            webRTCClient.handleRemoteDescription(answer, completion: { err  in
                self.isSetRemoteSDP = true
            })
        case .offer(let offer): //receving offer -> offer is the remoteSDP for the receiver
            print("Recevie offer")
            self.toUserUUID = websocketMessage.fromUUID!
            webRTCClient.handleRemoteDescription(offer, completion: { err in
                DispatchQueue.main.async {
                    self.isSetRemoteSDP = true
                }
            })
        case .bye:
            print("leave")
//            disconnect()
        default:
            break
        }
    }
    
}

extension VideoCallViewModel : WebSocketDelegate {
    func webSocket(_ webSocket: Websocket, didReceive data: WSMessage) {
        //received
        self.processSignalingMessage(data.content!,websocketMessage: data)
    }
    
    func webSocket(_ webSocket: Websocket, didConnected data : Bool) {
        DispatchQueue.main.async {
            self.isConnectd = data
        }
    }
}


enum SignalMessage {
    case none
    case candidate(_ message: RTCIceCandidate)
    case answer(_ message: RTCSessionDescription)
    case offer(_ message: RTCSessionDescription)
    case bye
    
    static func from(message: String) -> SignalMessage {
        if let dict = message.convertToDictionary() {
            var messageDict: [String: Any]?

            if dict.keys.contains("msg") {
                let messageStr = dict["msg"] as? String
                messageDict = messageStr?.convertToDictionary()
            } else {
                messageDict = dict
            }
            
            if let messageDict = messageDict,
                let type = messageDict["type"] as? String {
                
                if type == "candidate",
                    let candidate = RTCIceCandidate.candidate(from: messageDict) {
                    return .candidate(candidate)
                } else if type == "answer",
                    let sdp = messageDict["sdp"] as? String {
                    return .answer(RTCSessionDescription(type: .answer, sdp: sdp))
                } else if type == "offer",
                    let sdp = messageDict["sdp"] as? String {
                    return .offer(RTCSessionDescription(type: .offer, sdp: sdp))
                } else if type == "bye" {
                    return .bye
                }
                
            }
        }
        return none
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return nil
    }
}

extension RTCIceCandidate {
    func JSONData() -> Data? {
        let dict = ["type": "candidate",
                    "label": "\(self.sdpMLineIndex)",
                    "id": self.sdpMid,
                    "candidate": self.sdp
        ]
        return dict.JSONData
    }

    static func candidate(from: [String: Any]) -> RTCIceCandidate? {
        let sdp = from["candidate"] as? String
        let sdpMid = from["id"] as? String
        let labelStr = from["label"] as? String
        let label = (from["label"] as? Int32) ?? 0
        
        return RTCIceCandidate(sdp: sdp ?? "", sdpMLineIndex: Int32(labelStr ?? "") ?? label, sdpMid: sdpMid)
    }
}


extension Data {
    var toJSONString : NSString? {
        guard let obj = try? JSONSerialization.jsonObject(with: self,options: []),let data = try? JSONSerialization.data(withJSONObject: obj,options: [.prettyPrinted]),let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        
        return jsonStr
    }
}
