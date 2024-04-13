//
//  SFUConsumersManager.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 13/4/2024.
//

import Foundation
import Combine
import WebRTC
import SwiftUI

protocol SFUConsumserManagerDelegate : class {
    func SFUConsumserManager(_ message : Data,signalType: SFUSignalType,producerId : String?)
    func SFUConsumserManager(_ connectionStatus : RTCPeerConnectionState, consumerId : String)
}

class SFUConsumersManager : ObservableObject {
    @Published var sessionId : String? //In which session
    @Published var connectedConsumerMap : [SFUConsumer] = [] //Which consumer is connected
    @Published var pendingConsumer : [String : SFUConsumer] = [:] //Which consumer is consuming.
    private var callType : CallingType? = nil //Which is current calling type
    private var webSocket : Websocket?

    init(){
        self.connectedConsumerMap = []
        self.pendingConsumer = [:]
        self.webSocket = Websocket.shared
        self.webSocket?.sessionConsumerDelegate = self
    }
    
    //MARK: To Set up current session -> Which room is it
    func setUpSessionManager(_ sessionId : String,callType : CallingType){ //Calling this one first
        DispatchQueue.main.async{
            self.sessionId = sessionId
            self.callType =  callType
        }
    }
    
    func consumeProducer(producerId : String, producerInfo : SfuProducerUserInfo){ //Then this one...
        guard let callType = self.callType else {
            print("Calling Type is nil")
            return
        }
        
        let consumer = SFUConsumer(userInfo: producerInfo, producerId: producerId,type: callType)
        self.newPendingConsumer(producerID: producerId, consumer: consumer)
        consumer.sfuManagerDelegate = self
        consumer.start()
        consumer.sendOffer(type: callType)
    }
    
    func handleProducers(prodcuersList : [SfuProducerUserInfo]){
        print("Current Session Producer list : \(prodcuersList)")
        prodcuersList.forEach{ info in
            self.consumeProducer(producerId: info.producer_user_id, producerInfo: info)
        }
    }
    
    func processSignalingMessage(_ message: String,websocketMessage : WSMessage, clientId : String) -> Void {
//        print("processSignalingMessage(consumer) \(clientId)")
        var c : SFUConsumer
        print("Current pending consumer \(self.pendingConsumer)")
        print("Current connected consumer \(self.connectedConsumerMap)")
        if self.pendingConsumer[clientId] != nil { //is in pending list?
            c = self.pendingConsumer[clientId]!
        }else {
            //is connected but received
            guard let i = self.findConsumerIndexById(producerId: clientId) else {
                print("consumer not found from getConsumer")
                return
            }
            
            c = self.connectedConsumerMap[i]
        }
    
        let signalMessage = SignalMessage.from(message: message)
//
        switch signalMessage {
        case .candidate(let candidate):
//            print("Recevie candidate(CONSUMER)")
            if !c.isSetRemoteSDP {
//                print("Not yet set remote DESC before candidate(Consumer)............!!!!!!!!!!!!!")
                c.updateCandindateList(candindate: candidate)
            }else{
                let candindateList = c.getCandidateList()
                if !candindateList.isEmpty {
                    candindateList.forEach{ice in
                        c.webRTCClient?.handleCandidateMessage(ice,completion: { error in
                            DispatchQueue.main.async {
                                c.remoteCanindate += 1
                            }
                        })
                    }
                    c.cleanCandidateList()
                }
                c.webRTCClient?.handleCandidateMessage(candidate,completion: { error in
                    DispatchQueue.main.async {
                       c.remoteCanindate += 1
                    }
                })
            }

            break
        case .answer(let answer):
//            print("Recevie answer(CONSUMER)") //receving answer -> offer is the remoteSDP for the receiver
//
            if c.isSetRemoteSDP {
//                debugPrint("Not need to send more answer")
                return
            }

            c.webRTCClient?.handleRemoteDescription(answer, completion: { err  in
                DispatchQueue.main.async {
                   c.isSetRemoteSDP = true //JUST FOR TESTING
                }
            })
//            SoundManager.shared.stopPlaying()

            break
            //TODO:
        case .offer(let offer): //receving offer -> offer is the remoteSDP from the receiver
//            print("Recevie offer")
            break
        case .bye:
//            print("leave")
            break
        default:
            break
        }
    }
    
    private func findConsumerIndexById(producerId : String) -> Int?{
        return self.connectedConsumerMap.firstIndex(where: {$0.clientId == producerId})
    }
    
    private func closeConsumer(producerId : String){
        guard let i = self.findConsumerIndexById(producerId: producerId) else {
            print("Close - Consumer not exist")
            return
        }
        if self.connectedConsumerMap.isEmpty {
            return
        }
        DispatchQueue.main.async {
            let c = self.connectedConsumerMap[i]
            self.connectedConsumerMap[i].DisConnect()
            self.connectedConsumerMap.remove(at: i)
       }
    }
    
    

    private func newPendingConsumer(producerID : String,consumer : SFUConsumer) {
        print("adding \(producerID)")
        DispatchQueue.main.async {
            self.pendingConsumer[producerID] = consumer
        }

    }
    
    private func removeConsumerFromPendingConsumer(producerID : String) {
        DispatchQueue.main.async {
            self.pendingConsumer.removeValue(forKey: producerID)
        }
    }
    
    private func addConsumer(consumer : SFUConsumer) {
        print("Adding Consumer into the list \(consumer.clientId)")
        DispatchQueue.main.async {
            self.connectedConsumerMap.append(consumer)
        }
    }
    
    func closeAllConsumer(){
        DispatchQueue.main.async {
            self.connectedConsumerMap.forEach({ $0.webRTCClient?.disconnect()})
            self.pendingConsumer.forEach({$0.value.webRTCClient?.disconnect()})
            self.reset()
        }
    }
    
    private func reset(){
        self.sessionId = nil
        self.callType = nil
        self.connectedConsumerMap = []
        self.pendingConsumer = [:]
    }
    

}

extension SFUConsumersManager : SFUConsumserManagerDelegate {
    func SFUConsumserManager(_ message : Data,signalType: SFUSignalType,producerId : String?){
        
        guard let sdpStr = message.toJSONString else {
            return
        }
        
        let sdp = sdpStr as String
        guard let producerId = producerId else {
            print("Producer not yet set.")
            return
        }
//        print("Handling singling for \(producerId)")
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
//            print("CLOSED")
//            webSocket?.sendSFUClose(sessionId: sessionId)
            break
        }
        
    }

    func SFUConsumserManager(_ connectionStatus : RTCPeerConnectionState, consumerId : String) {
        guard let pendingConsumer = self.pendingConsumer[consumerId] else{
            print("Consumer Not found from pending consumer")
            return
        }
        print("Consumer Connected \(consumerId)")
        self.addConsumer(consumer: pendingConsumer)
        self.removeConsumerFromPendingConsumer(producerID: consumerId)
    }
}

extension SFUConsumersManager : WebSocketDelegate {
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
//                    print("received an ice candindate(Consumer)！！！！！！！！！！！！！！")
                    self.processSignalingMessage(resp.ice_candidate_type,websocketMessage: data, clientId: resp.client_id)
                }
            }catch(let err){
                print(err.localizedDescription)
            }
            break
            
        case EventType.SFU_EVENT_SEND_NEW_PRODUCER.rawValue:
//            print("New Producer In...")
            do{
                //Receive ice candindate.
                let resp = try JSONDecoder().decode(SfuNewProducerResp.self, from: Data(content.utf8))
                self.consumeProducer(producerId: resp.producer_info.producer_user_id, producerInfo: resp.producer_info)

            }catch(let err){
                print(err.localizedDescription)
            }
            break
            
        case EventType.SFU_EVENT_CONSUMER_CLOSE.rawValue:
            do{
                let resp = try JSONDecoder().decode(SFUCloseConnectionResp.self, from: Data(content.utf8))
                self.closeConsumer(producerId: resp.producer_id)
            }catch(let err){
                print(err.localizedDescription)
            }
        
            break
        case EventType.SFU_EVENT_PRODUCER_CONNECTED.rawValue:
            do{
                //Receive ice candindate.
//                print("SFU_conncected.")
                let resp = try JSONDecoder().decode(SFUConnectSessionResp.self, from: Data(content.utf8))
//                print(resp.session_producers)
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
