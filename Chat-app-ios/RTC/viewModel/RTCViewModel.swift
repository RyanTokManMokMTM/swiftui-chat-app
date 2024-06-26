//
//  RTCViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 14/5/2023.
//


import Foundation
import WebRTC
import SwiftUI
import Combine

enum CallingType : String {
    case Voice
    case Video
    
    var rawValue: String {
        switch self {
        case .Voice : return "voice"
        case .Video : return "video"
        }
    }
}

enum SFUMediaType : String {
    case Audio
    case Video
    case Speaker
    
    var rawValue: String {
        switch self {
        case .Audio : return "audio"
        case .Video : return "video"
        case .Speaker : return "speaker"
        }
    }
}

enum CallingStatus : String {
    case Connected
    case Connecting
    case Incoming
    case Ended
    case Pending
    
    var rawValue: String{
        switch(self){
        case .Connected : return "Connected"
        case .Connecting : return "Connecting"
        case .Incoming : return "Incoming"
        case .Ended : return "Ended"
        case .Pending : return "Connected"
        }
    }
}

enum CameraPossion {
    case front
    case back
}

class RTCViewModel : ObservableObject {
    @Published var isConnectd : Bool = false
    @Published var isSetLoaclSDP : Bool = false
    @Published var isSetRemoteSDP : Bool = false
    @Published var localCanindate : Int = 0
    @Published var remoteCanindate : Int = 0
    @Published var connectionStatus : RTCPeerConnectionState = .closed
    @Published var IsReceivedMessage : Bool = false
    @Published var receivedMessage : String = ""
    
    @Published var remoteVideoTrack : RTCVideoTrack?
    @Published var localVideoTrack : RTCVideoTrack?
    
    @Published var refershRemoteTrack : Bool = false
    @Published var refershLocalTrack : Bool = false
    
    @Published var callState : CallingStatus = .Pending
    @Published var isIncomingCall : Bool = false
    @Published var isMinimized : Bool = false
    @Published var callingType : CallingType = .Voice
    
    @Published var isSpeakerOn : Bool = true
    @Published var isAudioOn : Bool  = true
    @Published var isVideoOn : Bool = true
    @Published var camera : CameraPossion = .front
    @Published var room : ActiveRooms? = nil
    //MARK: Singal
    var webSocket : Websocket?
    var queue = [String]()
    var webRTCClient : WebRTCClient?
    var toUserUUID : String?
    var userName : String?
    var userAvatar : String?
    
    
    init(){
        self.webSocket = Websocket.shared
        self.webSocket?.delegate = self
//        createNewPeer()
    
    }

    
    func createNewPeer(){
        if self.webRTCClient != nil {
            return
        }
        self.webRTCClient = WebRTCClient()
        self.webRTCClient?.setUp(callType: self.callingType)
        self.webRTCClient?.delegate = self
    }
    
    
    func start( type : CallingType,room : ActiveRooms){
        self.callingType = type
        self.room = room
        createNewPeer()
        prepare()
    }
    
    func voicePrepare(){
        self.webRTCClient?.hideVideo()
    }
    
    func videoPrepare() {
        if let client = self.webRTCClient,!client.VideoIsEnable{
            self.webRTCClient?.showVideo()
        }
    }
    
    func prepare(){
        remoteVideoTrack = self.webRTCClient?.remoteVIdeoTrack
        localVideoTrack = self.webRTCClient?.localVideoTrack
        refershRemoteTrack = true
        refershLocalTrack = true
    }
    
    
    private func clear(){
        self.webSocket = nil
        self.webRTCClient = nil
        self.localVideoTrack = nil
        self.remoteVideoTrack = nil
        refershRemoteTrack = true
        refershLocalTrack = true
        self.room = nil
        self.isMinimized = false
    }
    
    
    private func Reset() {
        DispatchQueue.main.async{
            self.isSetLoaclSDP = false
            self.isSetRemoteSDP = false
            self.localCanindate = 0
            self.localCanindate = 0
            self.refershRemoteTrack = true
            self.refershLocalTrack = true
            self.room = nil
            
            self.toUserUUID = nil
            self.userName = nil
            self.userAvatar = nil
            self.callingType = .Voice
            self.isMinimized = false
        }
    }
    
    func DisConnect() {
        self.webRTCClient?.disconnect()
        self.Reset()
        self.callState = .Pending //waiting...
        self.webRTCClient = nil
        self.createNewPeer()
    }

}

extension RTCViewModel {
    func sendOffer(type : CallingType){
        if self.toUserUUID == nil {
            print("please input candindate uuid")
            return
        }
        if self.isConnectd && !self.isSetRemoteSDP && !self.isSetLoaclSDP {
            //is connecte and not set remote and not set ans
            print("sending offer")
            guard let url = Bundle.main.url(forResource: "call", withExtension: ".mp3") else {
                self.callState = .Ended
                return
            }
            
            SoundManager.shared.playSound(url: url)
            
            self.webRTCClient?.offer(){ sdp in
                DispatchQueue.main.async {
                    self.isSetLoaclSDP = true
                }
                
                //DO WE SEND USER NAME AND UUID AND AVATAR TOO?
                if let sdpData = sdp.JSONData(type: type) {
                    //send via websocket
                    print("sendeing offer signal")
                    self.sendSingleMessage(sdpData)

                }else {
                    print("SDP sending ferror")
                }
            }
        }
    }
    

    
    func sendAnswer(type : CallingType){
        if self.toUserUUID == nil {
            print("please input candindate uuid")
            return
        }
        
        if self.isConnectd && self.isSetRemoteSDP && !self.isSetLoaclSDP{
            self.webRTCClient?.answer(){ sdp in
                DispatchQueue.main.async {
                    self.isSetLoaclSDP = true
                }
                
                if let sdpData = sdp.JSONData(type: type) {
                    //send via websocket
                    self.sendSingleMessage(sdpData)
                }
            }
        }
                            
    }
    
    func sendDisconnect(){
        let dict = ["type" : "bye"]
        if let data = dict.JSONData{
            self.sendSingleMessage(data)
        }
    }
}

extension RTCViewModel : WebRTCClientDelegate{
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCPeerConnectionState) {
        DispatchQueue.main.async {
            self.connectionStatus = state
            switch state {
            case .connected:
                print("RTCPeerConnectionState changed connted")
                SoundManager.shared.stopPlaying()
                self.callState = .Connected
            case .disconnected,.failed, .closed:
                print("RTCPeerConnectionState changed disconnected")
                self.callState = .Ended
            case .new, .connecting:
                self.callState = .Connecting
            @unknown default:
                break
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, sendData data: Data) {
        self.sendSingleMessage(data)
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCMediaStream) {
        DispatchQueue.main.async{
            self.refershRemoteTrack = true
            
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("receivd a local candindate!")
        guard let candinateData = candidate.JSONData() else {
            print("candindate failed")
            return
        }
//        print("To send SDP candiate : \(candinateData.toJSONString)")
        DispatchQueue.main.async {
            self.localCanindate += 1
        }
        self.sendSingleMessage(candinateData)
        //send to
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("received a message via data channel")
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? ("Binary \(data.count) bytes")
            self.receivedMessage = message
            self.IsReceivedMessage = true
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeIceConnectionState state: RTCIceConnectionState){
        
       
    }
}



extension RTCViewModel {
    func sendSingleMessage(_ message : Data, type : RTCType = .single) {
        guard let sdpStr = message.toJSONString else {
            return
        }
        
        guard let userId = self.toUserUUID else {
            print("userId is nil")
            return
        }
        let sdp = sdpStr as String

        webSocket?.sendRTCSignal(toUUID: userId, sdp: sdp,type: type)
    }
    
    func processSignalingMessage(_ message: String,websocketMessage : WSMessage) -> Void {
        if self.webRTCClient == nil {
            self.createNewPeer()
        }
        guard let webRTCClient = webRTCClient else { return }
        print(message)
        let signalMessage = SignalMessage.from(message: message)
        switch signalMessage {
        case .candidate(let candidate):
            print("candindate")
            print(candidate)
            webRTCClient.handleCandidateMessage(candidate,completion: { error in
                DispatchQueue.main.async {
                    self.remoteCanindate += 1
                }

            })
            break
        case .answer(let answer):
            print("Recevie answer:") //receving answer -> offer is the remoteSDP for the receiver
            
            if self.isSetRemoteSDP {
                debugPrint("Not need to send more answer")
                return
            }

            webRTCClient.handleRemoteDescription(answer, completion: { err  in
                DispatchQueue.main.async {
                    self.isSetRemoteSDP = true //JUST FOR TESTING
                }
            })
            SoundManager.shared.stopPlaying()
            
            break
            //TODO:
        case .offer(let offer): //receving offer -> offer is the remoteSDP for the receiver
            print("Recevie offer")
            if self.isSetRemoteSDP{
                debugPrint("SDP is already set")
                return
            }
            

            webRTCClient.handleRemoteDescription(offer, completion: { err in
                DispatchQueue.main.async {
                    self.isSetRemoteSDP = true
                }
            })
            print(SignalMessage.getCallType(message: message))
            DispatchQueue.main.async{
                self.callState = .Incoming
                self.toUserUUID = websocketMessage.fromUUID!
                self.userName = websocketMessage.fromUserName!
                self.userAvatar = websocketMessage.avatar!
                self.callingType = SignalMessage.getCallType(message: message)
                withAnimation{
                    self.isIncomingCall = true
                }
//                NSDataAsset(name: "ringing")
                guard let url = Bundle.main.url(forResource: "ringing", withExtension: ".mp3") else {
                    return
                }
                SoundManager.shared.playSound(url: url)
            }
            break
        case .bye:
            print("leave")
            DispatchQueue.main.async{
                self.callState = .Ended
            }
            break
        default:
            break
        }
    }
    
}

extension RTCViewModel {
    func mute()  {
        DispatchQueue.main.async {
            self.webRTCClient?.mute()
            self.isAudioOn = false
        }
    }
    
    func unmute(){
        DispatchQueue.main.async {
            self.webRTCClient?.unmute()
            self.isAudioOn = true
        }
    }
    
    func speakerOn(){
        DispatchQueue.main.async {
            self.webRTCClient?.speakerOn()
            self.isSpeakerOn = true
        }
    }
    
    func videoOff(){
        DispatchQueue.main.async {
            self.webRTCClient?.hideVideo()
            self.isVideoOn = false
        }
    }
    
    func videoOn(){
        DispatchQueue.main.async {
            self.webRTCClient?.showVideo()
            self.isVideoOn = true
        }
    }
    
    func speakerOff(){
        DispatchQueue.main.async {
            self.webRTCClient?.speakerOff()
            self.isSpeakerOn = false
        }
    }
    
    func changeCamera(){
        guard let _ =  self.webRTCClient?.stopCature() else {
            return
        }
        DispatchQueue.main.async {
            if self.camera == .front{
                self.webRTCClient?.changeCamera(possion: .back)
                self.camera = .back
            }else if self.camera == .back {
                self.webRTCClient?.changeCamera(possion: .front)
                self.camera = .front
            }
        }
    }
}


extension RTCViewModel : WebSocketDelegate {
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

//For SFU

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
    
    static func getCallType(message: String) -> CallingType {
        if let dict = message.convertToDictionary() {
            var messageDict: [String: Any]?
            
            if dict.keys.contains("msg") {
                let messageStr = dict["msg"] as? String
                messageDict = messageStr?.convertToDictionary()
            } else {
                messageDict = dict
            }
            
            if let messageDict = messageDict,
               let type = messageDict["call"] as? String {
                
                if type == "voice"{
                    return .Voice
                } else if type == "video" {
                    return .Video
                }
                
            }
        }
        return .Voice
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
//                    "sdpMLineIndex": "\(self.sdpMLineIndex)",
//                    "sdpMid": self.sdpMid,
                    "candidate": self.sdp
        ]
        return dict.JSONData
    }

    static func candidate(from: [String: Any]) -> RTCIceCandidate? {
        let sdp = from["candidate"] as? String
//        let sdpMid = from["sdpMid"] as? String
//        let labelStr = from["sdpMLineIndex"] as? String
//        let label = (from["sdpMLineIndex"] as? Int32) ?? 0
        return RTCIceCandidate(sdp: sdp ?? "", sdpMLineIndex: 0, sdpMid: "")
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
