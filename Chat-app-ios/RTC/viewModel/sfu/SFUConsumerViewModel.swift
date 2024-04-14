//
//  SFUConsumer.swift
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
struct Consumer {
    let producerInfo : SfuProducerUserInfo
    let rtcClient : WebRTCClient
}

//For current user used.
//MARK: same as
class SFUConsumer  : ObservableObject{
    let uuid : String = UUID().uuidString
//    @Published var index : Int
    @Published var isVideoOn : Bool = true
    @Published var isAudioOn : Bool = true
    @Published var isSpeakerOn : Bool = true

    
    @Published var isConnectd : Bool = false
    @Published var isSetLoaclSDP : Bool = false
    @Published var isSetRemoteSDP : Bool = false
    @Published var localCanindate : Int = 0
    @Published var remoteCanindate : Int = 0
    @Published var connectionStatus : RTCPeerConnectionState = .closed
    @Published var IsReceivedMessage : Bool = false
    @Published var receivedMessage : String = ""

    @Published var remoteVideoTrack : RTCVideoTrack?
    @Published var remoteAudioTrack : RTCAudioTrack?
    @Published var localVideoTrack : RTCVideoTrack?

    @Published var refershRemoteTrack : Bool = false
    @Published var refershLocalTrack : Bool = false

    @Published var callState : CallingStatus = .Pending
    @Published var isIncomingCall : Bool = false
    @Published var callingType : CallingType = .Voice

    @Published var camera : CameraPossion = .front

    @Published var clientId : String? = nil
    @Published var userInfo : SfuProducerUserInfo
    
    private var candidateList : [RTCIceCandidate] = []
    var sfuManagerDelegate : SFUConsumserManagerDelegate?
    var webRTCClient : WebRTCClient?

    
    
    init(userInfo : SfuProducerUserInfo,producerId : String,type : CallingType){
        self.userInfo = userInfo
        self.clientId = producerId
        self.callingType = type
    }
    
    func createNewPeer(){
        if self.webRTCClient != nil {
            return
        }
        self.webRTCClient = WebRTCClient()
        self.webRTCClient?.setUp(isProducer: false,callType: self.callingType)
        self.webRTCClient?.delegate = self
    }
    
    
    func start(){
        createNewPeer()
        prepare()
    }
    
    func updateCandindateList(candindate : RTCIceCandidate){
        DispatchQueue.main.async {
            self.candidateList.append(candindate)
        }
    }
    
    func getCandidateList() -> [RTCIceCandidate]{
        return self.candidateList
    }
    
    func cleanCandidateList(){
        DispatchQueue.main.async {
            self.candidateList.removeAll()
        }
    }

    
    func prepare(){
        self.remoteVideoTrack = self.webRTCClient?.remoteVIdeoTrack
        self.remoteAudioTrack = self.webRTCClient?.remoteAudioTrack
        self.refershRemoteTrack = self.webRTCClient?.refershRemoteTrack ?? false
    }
    
    func updateMediaStataus(mediaType : String, isOn : Bool){
        DispatchQueue.main.async{
            switch(mediaType){
            case SFUMediaType.Audio.rawValue:
                self.isAudioOn = isOn
                break
            case SFUMediaType.Video.rawValue:
                self.isVideoOn = isOn
                break
            case SFUMediaType.Speaker.rawValue:
                self.isSpeakerOn = isOn
                break
            default:
                print("unknow type")
                break
            }
        }
    }
    

    private func clear(){
//        self.sessionId = nil
        self.clientId = nil
//        self.webSocket = nil
        self.webRTCClient = nil
        self.localVideoTrack = nil
        self.remoteVideoTrack = nil
        refershRemoteTrack = false
        refershLocalTrack = false
    }
    
    
    private func Reset() {
        DispatchQueue.main.async{
            self.isSetLoaclSDP = false
            self.isSetRemoteSDP = false
            self.localCanindate = 0
            self.localCanindate = 0
            self.refershRemoteTrack = true
            self.refershLocalTrack = true
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

extension SFUConsumer {
    func sendOffer(type : CallingType){
        print("Sending Consumer offer....")
        if !self.isSetRemoteSDP && !self.isSetLoaclSDP {
            self.webRTCClient?.offer(){ sdp in
                DispatchQueue.main.async {
                    self.isSetLoaclSDP = true
                }
                
                //DO WE SEND USER NAME AND UUID AND AVATAR TOO?
                if let sdpData = sdp.JSONData(type: type) {
                    //send via websocket
                    print("sendeing offer signal")
                    self.sfuManagerDelegate?.SFUConsumserManager(sdpData, signalType: .SDP, producerId: self.clientId)

                }else {
                    print("SDP sending ferror")
                }
            }
        }
    }
    

}

extension SFUConsumer : WebRTCClientDelegate{
    func webRTCClient(_ client: WebRTCClient, didReceivedRemoteStream stream: RTCMediaStream) {
        
    }

    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCPeerConnectionState) {
        DispatchQueue.main.async {
            self.connectionStatus = state
            switch state {
            case .connected:
//                SoundManager.shared.stopPlaying()
                self.callState = .Connected
                print("(Consumer)Connected.")
                BenHubState.shared.AlertMessage(sysImg: "phone.connection", message: "\(self.userInfo.producer_user_name) joined the room.")
                if let clientId = self.clientId {
                    self.sfuManagerDelegate?.SFUConsumserManager(state, consumerId: clientId)
                }
     
            case .closed,.disconnected,.failed:
                print("(Consumer)Ended.")
                self.callState = .Ended
                BenHubState.shared.AlertMessage(sysImg: "phone.down.fill", message: "\(self.userInfo.producer_user_name) left the room.")

            case .new,.connecting:
                print("(Consumer)Connecting.")
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
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("receivd a local candindate!")
        guard let candinateData = candidate.JSONData() else {
            print("candindate failed")
            return
        }
        DispatchQueue.main.async {
            self.localCanindate += 1
        }
        self.sfuManagerDelegate?.SFUConsumserManager(candinateData, signalType: .Candinate,producerId: self.clientId)
    
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
        print("Consuming Producer Iceeeeeee Connection Status Changed :\(state)")
        
       
    }
}
