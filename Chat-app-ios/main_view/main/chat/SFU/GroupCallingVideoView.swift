//
//  GroupCallingVideoView.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 1/4/2024.
//

import SwiftUI
import AVFoundation

struct GroupCallingVideoView: View {
    //One prodcuer
    //Many Consumer
    var sessionId : String? = nil
    @StateObject private var ws = Websocket.shared
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var cosnumerVM : SFUConsumerManager
    @State private var messageToWebRTC : String = ""
    let columns = Array(repeating: GridItem(spacing: 10, alignment: .center), count: 2)
   
    var body: some View {
        VStack{
            ScrollView(.vertical,showsIndicators: false){
                LazyVGrid(columns: self.columns,spacing: 5){
                    renderProducerStreaming()
                    if !self.cosnumerVM.consumerMap.isEmpty {
                        ForEach(0..<self.cosnumerVM.consumerMap.count,id:\.self) { i in
                            ConsumerVideoInfo(index: i)
                                .environmentObject(cosnumerVM)
                                .padding(.horizontal,5)
                    
                    }
                 
                
                    }
                }
            }
            callingBtn()
        }
//        .onChange(of: self.producerVM.callState){ state in
//                            print("State Changed : \(state)")
//                            if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
//                                DispatchQueue.main.async {
//                                    onClose()
//                                }
//                            }
//                        }

    }
    
   
    @ViewBuilder
    private func renderProducerStreaming() -> some View {
    
        RTCVideoView(webClient: self.producerVM.webRTCClient, isRemote: false, isVoice: false,refershTrack: Binding<Bool>(get: {return self.producerVM.refershLocalTrack},
                                                                                                                                              set: { p in self.producerVM.refershLocalTrack = p}))
        .frame(width: 180,height: 250)
        .clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners]))
        .background(Color.black.clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .overlay(alignment: .bottomLeading){
            HStack(spacing:8){
                AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                    img
                        .resizable()
                        .aspectRatio( contentMode: .fill)
                        .frame(width: 10,height: 10)
                        .clipShape(Circle())
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width: 10,height: 10)
                })
                .padding(.vertical,5)
                .padding(.horizontal,3)
                
                Text(self.userVM.profile?.name ?? "--")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .bold()
                    .padding(.vertical,5)
                
                
                
                Text(self.producerVM.callState == .Connected ? "Connected" : "Connecting...")
                    .font(.system(size: 10))
                    .bold()
                    .foregroundColor(.white)
                
                
            }
        }
    
    }
    
    
    private func onClose(){
        self.producerVM.sendDisconnect()
        self.producerVM.DisConnect()
        self.producerVM.isIncomingCall = false
        self.cosnumerVM.closeAllConsumer()
    }
    
    @ViewBuilder
    private func callingBtn() -> some View {
        HStack{
            Button(action: {
                if self.producerVM.isAudioOn {
                    self.producerVM.mute()
                }else {
                    self.producerVM.unmute()
                }
            }){
                Image(systemName: self.producerVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }
           
            }
            Spacer()
            Button(action: {
                if self.producerVM.isSpeakerOn {
                    self.producerVM.speakerOff()
                }else {
                    self.producerVM.speakerOn()
                }
            }){
                Image(systemName: self.producerVM.isSpeakerOn ? "speaker.slash" :  "speaker.wave.3.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                onClose()
            }){
                Image(systemName: "phone.down.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding(30)
                    .background{
                        Circle()
                            .fill(.red)
                    }
            }
            Spacer()
            Button(action: {
                if self.producerVM.isVideoOn {
                    self.producerVM.videoOff()
                }else {
                    self.producerVM.videoOn()
                }
            }){
                Image(systemName: self.producerVM.isVideoOn ? "video.slash" : "video.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                self.producerVM.changeCamera()
            }){
                Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            
        }.padding(.horizontal)
    }

}


struct ConsumerVideoInfo : View {
    @EnvironmentObject private var consumerVM : SFUConsumerManager
    var index : Int
    var body: some View {
        RTCVideoView(webClient: consumerVM.consumerMap[index].webRTCClient, isRemote: true, isVoice: false,
                         refershTrack: Binding<Bool>(get: {return consumerVM.consumerMap[index].refershRemoteTrack},
                         set: { p in consumerVM.consumerMap[index].refershRemoteTrack = p}))

            .frame(width: 180,height: 250)
            .clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners]))
            .background(consumerVM.consumerMap[index].webRTCClient?.remoteVIdeoTrack == nil ?  Color.red.clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])):  Color.black.clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
            .overlay(alignment: .bottomLeading){
                HStack(spacing:5){
                    AsyncImage(url: consumerVM.consumerMap[index].userInfo.AvatarURL, content: { img in
                        img
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: 10,height: 10)
                            .clipShape(Circle())
                        
                    }, placeholder: {
                        ProgressView()
                            .frame(width: 10,height: 10)
                    })
                    .padding(.vertical,5)
                    .padding(.horizontal,3)
                    
                    Text(consumerVM.consumerMap[index].userInfo.producer_user_name)
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                        .bold()
                        .padding(.vertical,5)
                    
                    Text(consumerVM.consumerMap[index].callState == .Connected ? "Connected" : "Connecting...")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                        .bold()
                        .padding(.horizontal,5)
                }
            }
        
    
    }
}
