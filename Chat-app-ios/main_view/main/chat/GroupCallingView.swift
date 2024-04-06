//
//  GroupCallingView.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import SwiftUI
struct GroupCallingView: View {
    //One prodcuer
    //Many Consumer
    var sessionId : String? = nil
    @StateObject private var ws = Websocket.shared
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var cosnumerVM : SFUConsumerManager
    let columns = Array(repeating: GridItem(spacing: 10, alignment: .center), count: 4)
    @State private var messageToWebRTC : String = ""
    var body: some View {
        VStack{
            ScrollView(.vertical,showsIndicators: false){
                LazyVGrid(columns: self.columns,spacing: 5){
                    renderProducerStreaming()
                    
//                    ForEach(self.$cosnumerVM.consumerMap,id:\.clientId) { consumer in
//                        ConsumerInfo(consumer: consumer)
//                            .padding(.horizontal,5)
//                    }
                }
                .padding(.horizontal,10)
            }
            
            Text("Received message : \(self.producerVM.receivedMessage)")
            
            TextField("RTC Message", text: $messageToWebRTC)
                .padding()
                .background(BlurView(style: .regular).clipShape(CustomConer(coners: .allCorners)))
                 
            
            Button(action: {
                sendData()
            }){
                Text("Send message")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue.cornerRadius(10))
            }
//
            
            Button(action: {
                withAnimation{
                    DispatchQueue.main.async { //TODO: Send disconnected signal and Disconnect and reset all RTC
                        self.producerVM.sendDisconnect()
                        self.producerVM.DisConnect()
                        self.producerVM.isIncomingCall = false
                        
                    }
                }
            }){
                Text("Return")
                    .foregroundColor(.red)
                    .background(Color.blue.cornerRadius(10))
            }
        }
        .onChange(of: self.producerVM.callState){ state in
                            print("State Changed : \(state)")
                            if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
                                DispatchQueue.main.async {
                                    self.producerVM.isIncomingCall = false
                                    self.producerVM.DisConnect()
                                }
                            }
                        }

    }
    
    
    private func sendData(){
        if self.messageToWebRTC.isEmpty {
            return
        }
        guard let data = self.messageToWebRTC.data(using: .utf8) else {
            print("RTC message to data filed")
            return
        }
        DispatchQueue.main.async {
            self.producerVM.webRTCClient?.sendData(data)
            self.messageToWebRTC.removeAll()
        }
    }
    
    @ViewBuilder
    private func renderProducerStreaming() -> some View {
        VStack(spacing:0){
            AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                img
                    .resizable()
                    .aspectRatio( contentMode: .fill)
                    .frame(width: 45,height: 45)
                    .clipShape(Circle())
                
            }, placeholder: {
                ProgressView()
                    .frame(width: 40,height: 40)
            })
            .padding(.top,10)
            
            Text(self.userVM.profile?.name ?? "--")
                .font(.system(size: 12))
                .bold()
                .padding(.vertical,5)
            
            Text(self.producerVM.callState == .Connected ? "Connected" : "Connecting...")
                .font(.system(size: 8))
                .bold()
        }
        .frame(width: 100,height: 100)
        .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .background{
            ZStack{
                RTCVideoView(webClient: producerVM.webRTCClient, isRemote: false, isVoice: true,refershTrack: self.$producerVM.refershRemoteTrack).frame(width: 0, height: 0)
              
            }
            .hidden()
        }
    }

}


struct ConsumerInfo : View {
    @Binding var consumer : SFUConsumer
    var body: some View {
        VStack(spacing:0){
            VStack(spacing:0){
                AsyncImage(url: consumer.userInfo.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio( contentMode: .fill)
                        .frame(width: 45,height: 45)
                        .clipShape(Circle())
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width: 40,height: 40)
                })
                .padding(.top,10)
                
                Text(consumer.userInfo.producer_user_name)
                    .font(.system(size: 12))
                    .bold()
                    .padding(.vertical,5)
                
                Text(consumer.callState == .Connected ? "Connected" : "Connecting...")
                    .font(.system(size: 8))
                    .bold()
            }
            .frame(width: 100,height: 100)
            .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        }
        .frame(width: 100,height: 100)
        .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .background(
            ZStack{
                RTCVideoView(webClient: consumer.webRTCClient, isRemote: true, isVoice: true,refershTrack:
                                self.$consumer.refershLocalTrack).frame(width: 0, height: 0)
              
            }
            .hidden()
        )
    
    }
}
