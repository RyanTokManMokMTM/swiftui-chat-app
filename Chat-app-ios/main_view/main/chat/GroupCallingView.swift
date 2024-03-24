//
//  GroupCallingView.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import SwiftUI
struct TestCallingData : Identifiable {
    let id = UUID().uuidString
    let name : String
    let avatar : String
}

let dummyDataCalls = [
    TestCallingData(name: "test1", avatar: "test1"),
    TestCallingData(name: "test2", avatar: "test2"),
    TestCallingData(name: "test3", avatar: "test3"),
    TestCallingData(name: "test4", avatar: "test4"),
    TestCallingData(name: "test5", avatar: "test5"),
    TestCallingData(name: "test6", avatar: "test6"),
    TestCallingData(name: "test7", avatar: "test7"),
    TestCallingData(name: "test8", avatar: "test8"),
    TestCallingData(name: "test9", avatar: "test9"),
    TestCallingData(name: "test10", avatar: "test10"),
    TestCallingData(name: "test11", avatar: "test11"),
    TestCallingData(name: "test12", avatar: "test12"),
    TestCallingData(name: "test13", avatar: "test13"),
    TestCallingData(name: "test14", avatar: "test14"),
    TestCallingData(name: "test15", avatar: "test15"),
    TestCallingData(name: "test16", avatar: "test16"),
    
]

struct GroupCallingView: View {
    //One prodcuer
    //Many Consumer
    var sessionId : String? = nil
    @StateObject private var ws = Websocket.shared
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var cosnumerVM : SFUConsumerManager
    let columns = Array(repeating: GridItem(spacing: 10, alignment: .center), count: 4)
   
    var body: some View {
        VStack{
            ScrollView(.vertical,showsIndicators: false){
                LazyVGrid(columns: self.columns,spacing: 5){
                    renderProducerStreaming()
                    
                    ForEach(self.$cosnumerVM.consumerMap,id:\.clientId) { consumer in
                        ConsumerInfo(consumer: consumer)
                            .padding(.horizontal,5)
                    }
                }
                .padding(.horizontal,10)
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
    
    
    @ViewBuilder
    private func renderProducerStreaming() -> some View {
        RTCVideoView(track: self.producerVM.localVideoTrack,webClient: producerVM.webRTCClient, isRemote: false, isVoice: true,refershTrack: Binding<Bool>(get: {return self.producerVM.refershLocalTrack},set: { p in self.producerVM.refershLocalTrack = p}))
        .frame(width: 100,height: 100)
        .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .overlay{
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
        }
    }

}


struct ConsumerInfo : View {
    @Binding var consumer : SFUConsumer
    var body: some View {
        RTCVideoView(track: self.consumer.remoteVideoTrack,webClient: consumer.webRTCClient, isRemote: true, isVoice: true,refershTrack: Binding<Bool>(get: {return consumer.refershRemoteTrack},set: { p in consumer.refershRemoteTrack = p}))
        .frame(width: 100,height: 100)
        .background(BlurView().clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .overlay{
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
        }
    
    }
}
