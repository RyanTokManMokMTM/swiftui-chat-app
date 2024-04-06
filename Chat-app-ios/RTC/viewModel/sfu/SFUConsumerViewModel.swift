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

//Handling any message from webClient
protocol SFUConsumserManagerDelegate : class {
    func SFUConsumserManager(_ message : Data,signalType: SFUSignalType,producerId : String?)
}

@MainActor
class SFUConsumerManager : ObservableObject {
    @Published var sessionId : String?
    @Published var consumerMap : [SFUConsumer] = []
    private var callType : CallingType? = nil //by default
//    static var shared  = SFUConsumerManager()
    private var webSocket : Websocket?
    //Need to know for which client. and set it  to that webRTC client
    private var cancellables = [AnyCancellable]()
    init(){
        self.consumerMap.forEach({
                    let c = $0.objectWillChange.sink(receiveValue: { self.objectWillChange.send() })
                    self.cancellables.append(c)
                })
        self.webSocket = Websocket.shared
        self.webSocket?.sessionConsumerDelegate = self
    }
    
    func setUpSessionManager(_ sessionId : String,callType : CallingType){ //Calling this one first
        self.sessionId = sessionId
        self.callType =  callType
    }
    
    func consumeProducer(producerId : String, producerInfo : SfuProducerUserInfo){ //Then this one...
        guard let callType = self.callType else {
            print("Calling Type is nil")
            return
        }
        DispatchQueue.main.async {
            print("Starting Consuming Producer......")
            let consumer = SFUConsumer(userInfo: producerInfo, producerId: producerId)
            self.addConsumer(consumer: consumer)
           
            consumer.sfuManagerDelegate = self
            consumer.start()
            consumer.sendOffer(type: callType)
        }
    }
    
    func handleProducers(prodcuersList : [SfuProducerUserInfo]){
        prodcuersList.forEach{ info in
            print("Ready to consume : \(info.producer_user_id)")
            self.consumeProducer(producerId: info.producer_user_id, producerInfo: info)
        }
    }
    
    
    
    func processSignalingMessage(_ message: String,websocketMessage : WSMessage, clientId : String) -> Void {
        print("Process Signaling for(Consumer) \(clientId)")
        print(message)
        guard let i = self.findConsumerIndexById(producerId: clientId) else {
                print("consumer not found")
                return
            }
            
            let signalMessage = SignalMessage.from(message: message)
//    
            switch signalMessage {
            case .candidate(let candidate):
                print("Recevie candidate(CONSUMER)")
                if !self.consumerMap[i].isSetRemoteSDP {
                    print("Not yet set remote DESC before candidate(Consumer)............!!!!!!!!!!!!!")
                    self.consumerMap[i].updateCandindateList(candindate: candidate)
                }else{
                    let candindateList = self.consumerMap[i].getCandidateList()
                    if !candindateList.isEmpty {
                        candindateList.forEach{ice in
                            self.consumerMap[i].webRTCClient?.handleCandidateMessage(ice,completion: { error in
                                DispatchQueue.main.async {
                                    self.consumerMap[i].remoteCanindate += 1
                                }
                            })
                        }
                        self.consumerMap[i].cleanCandidateList()
                    }
                    self.consumerMap[i].webRTCClient?.handleCandidateMessage(candidate,completion: { error in
                        DispatchQueue.main.async {
                            self.consumerMap[i].remoteCanindate += 1
                        }
                    })
                }
    
                break
            case .answer(let answer):
                print("Recevie answer(CONSUMER)") //receving answer -> offer is the remoteSDP for the receiver
//
                if self.consumerMap[i].isSetRemoteSDP {
                    debugPrint("Not need to send more answer")
                    return
                }
    
                self.consumerMap[i].webRTCClient?.handleRemoteDescription(answer, completion: { err  in
                    DispatchQueue.main.async {
                        self.consumerMap[i].isSetRemoteSDP = true //JUST FOR TESTING
                    }
                })
    //            SoundManager.shared.stopPlaying()
    
                break
                //TODO:
            case .offer(let offer): //receving offer -> offer is the remoteSDP from the receiver
                print("Recevie offer")
                break
            case .bye:
                print("leave")
                break
            default:
                break
            }
        }
    
    private func findConsumerIndexById(producerId : String) -> Int?{
        
        return self.consumerMap.firstIndex(where: {$0.clientId == producerId})
    }
    
    private func addConsumer(consumer : SFUConsumer) {
        self.consumerMap.append(consumer)
    }

}

extension SFUConsumerManager : SFUConsumserManagerDelegate {
    func SFUConsumserManager(_ message : Data,signalType: SFUSignalType,producerId : String?){
        
        guard let sdpStr = message.toJSONString else {
            return
        }
        
        let sdp = sdpStr as String
        guard let producerId = producerId else {
            print("Producer not yet set.")
            return
        }
        print("Handling singling for \(producerId)")
        guard let sessionId = self.sessionId else{
            print("Session Id not yet set")
            return
        }
        switch(signalType){
        case .SDP:
            webSocket?.sendSFUSDPForConsumer(sessionId: sessionId,producerId: producerId,sdpType: sdp)
            break
        case .Candinate:
            webSocket?.sendSFUCandindate(sessionId: sessionId, isProducer: false, clientId: producerId, data: sdp)
            break
        case .Close:
            print("CLOSED")
//            webSocket?.sendSFUClose(sessionId: sessionId)
            break
        }
        
    }
}


extension SFUConsumerManager : WebSocketDelegate {
    func webSocket(_ webSocket: Websocket, didReceive data: WSMessage) {
        guard let content = data.content else{
            return
        }
        //Some event for consuming only
      
        switch(data.eventType){
        case EventType.SFU_EVENT_CONSUMER_SDP.rawValue:
            do{
                let resp = try JSONDecoder().decode(SFUConsumeProducerResp.self, from: Data(content.utf8))
                
                self.processSignalingMessage(resp.SDPType,websocketMessage: data, clientId: resp.producer_id)
            }catch(let err){
                print(err.localizedDescription)
            }
            break
        case EventType.SFU_EVENT_CONSUMER_ICE.rawValue:
            do{
                //Receive ice candindate.
                let resp = try JSONDecoder().decode(SFUSendIceCandindateReq.self, from: Data(content.utf8))
                if(!resp.is_producer) {
                    print("received an ice candindate(Consumer)！！！！！！！！！！！！！！")
                    self.processSignalingMessage(resp.ice_candidate_type,websocketMessage: data, clientId: resp.client_id)
                }
            }catch(let err){
                print(err.localizedDescription)
            }
            break
            
        case EventType.SFU_EVENT_SEND_NEW_PRODUCER.rawValue:
            print("New Producer In...")
            do{
                //Receive ice candindate.
                let resp = try JSONDecoder().decode(SfuNewProducerResp.self, from: Data(content.utf8))
                print(resp)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    self.consumeProducer(producerId: resp.producer_info.producer_user_id, producerInfo: resp.producer_info)
                }
             
            }catch(let err){
                print(err.localizedDescription)
            }
            break
            
        case EventType.SFU_EVENT_CONSUMER_CLOSE.rawValue:
            print("Handling a Producer left the session...")
        
            break
        case EventType.SFU_EVENT_PRODUCER_CONNECTED.rawValue:
            do{
                //Receive ice candindate.
                print("SFU_conncected.")
                let resp = try JSONDecoder().decode(SFUConnectSessionResp.self, from: Data(content.utf8))
                print(resp)
                self.handleProducers(prodcuersList: resp.session_producers)
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
        print("Websocket Connection State \(data)")
    }
}

//For current user used.
//MARK: same as
class SFUConsumer  : ObservableObject{
    @Published var isConnectd : Bool = false
    @Published var isSetLoaclSDP : Bool = false
    @Published var isSetRemoteSDP : Bool = false
    @Published var localCanindate : Int = 0
    @Published var remoteCanindate : Int = 0
    @Published var connectionStatus : RTCIceConnectionState = .closed
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

    @Published var isSpeakerOn : Bool = true
    @Published var isAudioOn : Bool  = true
    @Published var isVideoOn : Bool = true
    @Published var camera : CameraPossion = .front

    @Published var clientId : String? = nil
    @Published var userInfo : SfuProducerUserInfo
    
    private var candidateList : [RTCIceCandidate] = []
    var sfuManagerDelegate : SFUConsumserManagerDelegate?
    var webRTCClient : WebRTCClient?

    
    
    init(userInfo : SfuProducerUserInfo,producerId : String){
        self.userInfo = userInfo
        self.clientId = producerId
    }
    
    func createNewPeer(){
        if self.webRTCClient != nil {
            return
        }
        self.webRTCClient = WebRTCClient()
        self.webRTCClient?.setUp(isProducer: false)
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
        remoteVideoTrack = self.webRTCClient?.remoteVIdeoTrack
        remoteAudioTrack = self.webRTCClient?.remoteAudioTrack
        refershRemoteTrack = true
    }
    

    private func clear(){
//        self.sessionId = nil
        self.clientId = nil
//        self.webSocket = nil
        self.webRTCClient = nil
        self.localVideoTrack = nil
        self.remoteVideoTrack = nil
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
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState){
        print("Consuming Producer Connection Status Changed :\(state)")
        DispatchQueue.main.async {
            self.connectionStatus = state
            switch state {
            case .connected, .completed:
//                SoundManager.shared.stopPlaying()
                self.callState = .Connected
                print("(Consumer)Connected.")
            case .disconnected,.failed, .closed:
                print("(Consumer)Ended.")
                self.callState = .Ended
            case .new, .checking, .count:
                print("(Consumer)Connecting.")
                self.callState = .Connecting
            @unknown default:
                break
            }
        }
       
    }
}
