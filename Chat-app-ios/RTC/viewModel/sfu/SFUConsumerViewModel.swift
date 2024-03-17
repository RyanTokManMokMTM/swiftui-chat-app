//
//  SFUConsumerViewModel.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 10/3/2024.
//

import Foundation

class SFUConsumerViewModel : ObservableObject {
    //Handliner a list of consumer connection.
    @Published var consumers : [String : WebRTCClient] = [String : WebRTCClient]()
    
    func consumeProducer(sessionId : String,producerId : String){
        let rtcClient = WebRTCClient()
        rtcClient.setUp(isProducer: false)
        rtcClient.offer{ offerSDP in
            //Send to backend -> SFU_CONSUME
        }
        DispatchQueue.main.async {
            self.consumers[producerId] = rtcClient
        }
    }
    
    func setConsumerAnswner(producerID : String,ans : String){
        guard let rtcClient = self.consumers[producerID] else{
            print("rtcClient not found")
            return
        }
        //Handling message and set.
//        rtcClient.handleRemoteDescription()
    }
}
