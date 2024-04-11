//
//  SFUProdcuerViewModel.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import Foundation
import Combine
import WebRTC
import SwiftUI

//For current user used.
//MARK: same as
class SFProducerViewModel : ObservableObject {
    var room : ActiveRooms?
    @Published var isConnectd : Bool = false
    @Published var isSetLoaclSDP : Bool = false
    @Published var isSetRemoteSDP : Bool = false
    @Published var localCanindate : Int = 0
    @Published var remoteCanindate : Int = 0
    @Published var connectionStatus : RTCPeerConnectionState = .closed
    @Published var IsReceivedMessage : Bool = false
    @Published var receivedMessage : String = ""
    
    @Published var localVideoTrack : RTCVideoTrack?
    @Published var localAudioTrack : RTCAudioTrack?
    
    @Published var remoteVideoTrack : RTCVideoTrack?
    @Published var remoteAudioTrack : RTCAudioTrack?
    
    @Published var refershRemoteTrack : Bool = false
    @Published var refershLocalTrack : Bool = false
    
    @Published var callState : CallingStatus = .Pending
    @Published var isIncomingCall : Bool = false
    @Published var callingType : CallingType = .Voice
    
    @Published var isSpeakerOn : Bool = true
    @Published var isAudioOn : Bool  = true
    @Published var isVideoOn : Bool = true
    @Published var camera : CameraPossion = .front
    
    @Published var  sessionId : String? = nil //Chat group UUID.
    @Published var clientId : String? = nil
    
    private var candidateList : [RTCIceCandidate] = []
    //MARK: Singal
    var webSocket : Websocket?
    var webRTCClient : WebRTCClient?

    
    
    init(){
        self.webSocket = Websocket.shared
        self.webSocket?.sessionDelegate = self
        createNewPeer()
    
    }
    
    func createNewPeer(){
        if self.webRTCClient != nil {
            return
        }
        self.webRTCClient = WebRTCClient()
        self.webRTCClient?.setUp()
        self.webRTCClient?.delegate = self
    }
    
    
    func start(sessionId : String,clientId : String, room : ActiveRooms){
        self.sessionId = sessionId
        self.clientId = clientId
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
        localVideoTrack = self.webRTCClient?.localVideoTrack
//        localAudioTrack = self.webRTCClient?.localAudioTrack
        
//        remoteAudioTrack = self.webRTCClient?.remoteAudioTrack
        remoteVideoTrack = self.webRTCClient?.remoteVIdeoTrack
        refershRemoteTrack = true
        refershLocalTrack = true
    }
    
    
    private func clear(){
        self.sessionId = nil
        self.clientId = nil
        self.webSocket = nil
        self.webRTCClient = nil
        self.localVideoTrack = nil
        self.remoteVideoTrack = nil
        self.room = nil
        refershRemoteTrack = true
        refershLocalTrack = true
    }
    
    
    private func Reset() {
        DispatchQueue.main.async{
            self.isSetLoaclSDP = false
            self.isSetRemoteSDP = false
            self.localCanindate = 0
            self.localCanindate = 0
            self.refershRemoteTrack = true
            self.refershLocalTrack = true
            self.localVideoTrack = nil
            self.remoteVideoTrack = nil
            self.room = nil
//            self.toUserUUID = nil
//            self.userName = nil
//            self.userAvatar = nil
            self.callingType = .Voice
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

extension SFProducerViewModel {
    func sendOffer(type : CallingType){
        if self.isConnectd && !self.isSetRemoteSDP && !self.isSetLoaclSDP {
            //is connecte and not set remote and not set ans
            print("sending offer with sessionId :\(self.sessionId?.description ?? "KNOW.")")
//            guard let url = Bundle.main.url(forResource: "call", withExtension: ".mp3") else {
//                self.callState = .Ended
//                return
//            }
//            
//            SoundManager.shared.playSound(url: url)
            
            //Connecting...
            self.webRTCClient?.offer(){ sdp in
                DispatchQueue.main.async {
                    self.isSetLoaclSDP = true
                }
                
                print("OFFER: =====================================")
                print(sdp)
                print("OFFER END: =====================================")
                //DO WE SEND USER NAME AND UUID AND AVATAR TOO?
                if let sdpData = sdp.JSONData(type: type) {
                    //send via websocket
                    print("sendeing offer signal")
                    self.sendSingleMessage(sdpData,signalType: .SDP)

                }else {
                    print("SDP sending ferror")
                }
            }
        }
    }
    

    
//    func sendAnswer(type : CallingType){
////        if self.toUserUUID == nil {
////            print("please input candindate uuid")
////            return
////        }
//        
//        if self.isConnectd && self.isSetRemoteSDP && !self.isSetLoaclSDP{
//            self.webRTCClient?.answer(){ sdp in
//                DispatchQueue.main.async {
//                    self.isSetLoaclSDP = true
//                }
//                
//                if let sdpData = sdp.JSONData(type: type) {
//                    //send via websocket
//                    self.sendSingleMessage(sdpData,.SDP)
//                }
//            }
//        }
//                            
//    }
    
    func sendDisconnect(){
        let dict = ["type" : "bye"]
        if let data = dict.JSONData{
            self.sendSingleMessage(data,signalType: .Close)
        }
    }
}

extension SFProducerViewModel : WebRTCClientDelegate{
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCPeerConnectionState) {
        
        DispatchQueue.main.async {
            self.connectionStatus = state
            switch state {
            case .connected:
                self.callState = .Connected
                print("Produecer connection : \( self.callState)")
            case .disconnected,.failed, .closed:
                
                self.callState = .Ended
            case .new, .connecting:
                self.callState = .Connecting
            @unknown default:
                break
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, sendData data: Data) {
        print("TODO: Send Data")
//        self.sendSingleMessage(data)
    }
    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCMediaStream) {
        DispatchQueue.main.async {
            self.refershRemoteTrack = true
        }
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
        self.sendSingleMessage(candinateData,signalType: .Candinate)
        //send to
    
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        print("received a message via data channel")
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? ("Binary \(data.count) bytes")
            self.receivedMessage = message
            self.IsReceivedMessage = true
            
            print("Received message : -> \(message)")
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeIceConnectionState state: RTCIceConnectionState){
    
       
    }
}

extension SFProducerViewModel {
    func sendSingleMessage(_ message : Data,signalType: SFUSignalType) {
        guard let sdpStr = message.toJSONString else {
            return
        }
        
        let sdp = sdpStr as String
        guard let clientId = self.clientId else {
            print("Client Id not yet set")
            return
        }
        guard let sessionId = self.sessionId else{
            print("Session Id not yet set")
            return
        }
        switch(signalType){
        case .SDP:
            webSocket?.sendSFUSDP(sessionId: sessionId, sdpType: sdp)
            break
        case .Candinate:
            webSocket?.sendSFUCandindate(sessionId: sessionId, isProducer: true, clientId: clientId, data: sdp)
            break
        case .Close:
            print("CLOSED")
            webSocket?.sendSFUClose(sessionId: sessionId)
            break
        }
        
        
//        webSocket?.sendRTCSignalForSession(sessionId: sessionId, sdp: sdp)
//        webSocket?.sendRTCSignal(toUUID: self.toUserUUID!, sdp: sdp,type: type)
    }
    
    func processSignalingMessage(_ message: String,websocketMessage : WSMessage) -> Void {
        guard let webRTCClient = webRTCClient else { return }
        print(message)
        let signalMessage = SignalMessage.from(message: message)
  
        switch signalMessage {
        case .candidate(let candidate):
            
            print("Received ice :\(candidate.sdpMid)")
            print("Received ice :\(candidate.sdpMLineIndex)")
            print("Received ice :\(candidate.sdp)")
            if !isSetRemoteSDP {
                print("Not yet set remote DESC before candidate............!!!!!!!!!!!!!")
                self.candidateList.append(candidate)
            }else{
                if !self.candidateList.isEmpty {
                    self.candidateList.forEach{ice in
                        webRTCClient.handleCandidateMessage(ice,completion: { error in
                            DispatchQueue.main.async {
                                self.remoteCanindate += 1
                            }
                        })
                    }
                    self.candidateList.removeAll()
                }
                webRTCClient.handleCandidateMessage(candidate,completion: { error in
                    DispatchQueue.main.async {
                        self.remoteCanindate += 1
                    }
                })
            }
           
            break
        case .answer(let answer):
            print("ANS ==============================================") //receving answer -> offer is the remoteSDP for the receiver
            print(answer)
            print("ANS ==============================================")
            if self.isSetRemoteSDP {
                debugPrint("Not need to send more answer")
                return
            }

            webRTCClient.handleRemoteDescription(answer, completion: { err  in
                DispatchQueue.main.async {
                    self.isSetRemoteSDP = true //JUST FOR TESTING
                }
            })
//            SoundManager.shared.stopPlaying()
            
            break
            //TODO:
        case .offer(let offer): //receving offer -> offer is the remoteSDP from the receiver
            print("Recevie offer")
//            if self.isSetRemoteSDP{
//                debugPrint("SDP is already set")
//                return
//            }
//            
//
//            webRTCClient.handleRemoteDescription(offer, completion: { err in
//                DispatchQueue.main.async {
//                    self.isSetRemoteSDP = true
//                }
//            })
//            
//            DispatchQueue.main.async{
//                self.callState = .Incoming
////                self.toUserUUID = websocketMessage.fromUUID!
////                self.userName = websocketMessage.fromUserName!
////                self.userAvatar = websocketMessage.avatar!
//                self.callingType = SignalMessage.getCallType(message: message)
//                self.isIncomingCall = true
////                NSDataAsset(name: "ringing")
//                guard let url = Bundle.main.url(forResource: "ringing", withExtension: ".mp3") else {
//                    return
//                }
//                SoundManager.shared.playSound(url: url)
//            }
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

extension SFProducerViewModel {
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

extension SFProducerViewModel : WebSocketDelegate {
    func webSocket(_ webSocket: Websocket, didReceive data: WSMessage) {
        guard let content = data.content else{
            return
        }
        switch(data.eventType){
        case EventType.SFU_EVENT_PRODUCER_SDP.rawValue:
            do{
                let resp = try JSONDecoder().decode(SfuConnectSessionResp.self, from: Data(content.utf8))
                self.processSignalingMessage(resp.SDPType,websocketMessage: data)
            }catch(let err){
                print(err.localizedDescription)
            }
            break
        case EventType.SFU_EVENT_PRODUCER_ICE.rawValue:
            do{
                //Receive ice candindate.
                let resp = try JSONDecoder().decode(SFUSendIceCandindateReq.self, from: Data(content.utf8))
                if resp.is_producer{
                    print("received an ice candindate(Producer)！！！！！！！！！！！！！！")
                    self.processSignalingMessage(resp.ice_candidate_type,websocketMessage: data)
                }
            }catch(let err){
                print(err.localizedDescription)
            }
            break
        default:
            print("UNKNOW event :\(data.eventType ?? "--")")
            break
        }
    }
    
    func webSocket(_ webSocket: Websocket, didConnected data : Bool) {
        DispatchQueue.main.async {
            self.isConnectd = data
        }
    }
}
