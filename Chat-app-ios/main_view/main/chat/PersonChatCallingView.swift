//
//  VoiceCallingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/2/2023.
//

import SwiftUI

struct PersonChatCallingView: View {
    @Binding var isCallView : Bool
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var videoCallVM : RTCViewModel
    let data : ActiveRooms
    var body: some View {
//        ZStack(alignment: .bottomLeading){
            ZStack{
                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: true, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershRemoteTrack},
                                                                                                                                                      set: { p in self.videoCallVM.refershRemoteTrack = p}))
                .edgesIgnoringSafeArea(.all)
                .background(BlurView().edgesIgnoringSafeArea(.all))
                
            }

            .overlay(alignment:.bottomLeading){
                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: false, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershLocalTrack},
                                                                                                                                                      set: { p in self.videoCallVM.refershLocalTrack = p}))
                .frame(width: 150, height: 220)
                .cornerRadius(25)
                .padding()
                .background(BlurView().cornerRadius(25).padding())
            }
            .overlay(alignment: .top){
                HStack{
                    Button(action:{
                        DispatchQueue.main.async {
                            self.isCallView = false
                            //TODO: Disconnected...
                        }
                    }){
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(5)
                    }
                    .padding(5)
                    .background(BlurView().clipShape(Circle()))

                    Spacer()
                }
                .padding()

            }
        
    }
}

//struct VoiceCallingView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceCallingView(data: dummyContentList[0])
//    }
//}
