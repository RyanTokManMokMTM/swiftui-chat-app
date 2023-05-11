//
//  VoiceCallingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/2/2023.
//

import SwiftUI

struct VoiceCallingView: View {
    @Binding var isCallView : Bool
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var videoCallVM : VideoCallViewModel
    let data : ActiveRooms
    var body: some View {
//        ZStack(alignment: .bottomLeading){
            ZStack{
                RTCVideoView(track: self.videoCallVM.remoteVideoTrack,webClient: videoCallVM.webRTCClient, isRemote: true,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershRemoteTrack},
                                                                                                                                                      set: { p in self.videoCallVM.refershRemoteTrack = p}))
                .edgesIgnoringSafeArea(.all)
                .background(BlurView().edgesIgnoringSafeArea(.all))
                //                .background( BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all))
                
               
//                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
//                .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
//                .padding(.bottom)
//                .padding(.horizontal)
//                //                .edgesIgnoringSafeArea(.all)
                
                
            }

            .overlay(alignment:.bottomLeading){
                RTCVideoView(track: self.videoCallVM.localVideoTrack,webClient: videoCallVM.webRTCClient, isRemote: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershLocalTrack},
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


//                    AsyncImage(url: data.AvatarURL, content: {img in
//                        img
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width:120,height: 120)
//                            .clipShape(Circle())
//
//
//
//                    }, placeholder: {
//                        ProgressView()
//                            .frame(width:120,height: 120)
//
//                    })
//
//                    Text(data.name ?? "UNKNOW")
//                        .font(.title2)
//                        .bold()
//                        .foregroundColor(.white)
//
//                    Text("Caling...")
//                        .foregroundColor(.white)

//                    Spacer()
//
//                    HStack{
//                        Button(action:{}){
//                            VStack(spacing:5){
//                                Image(systemName: "mic.fill")
//                                    .imageScale(.large)
//                                    .scaleEffect(1.1)
//
//                                Text("Mute")
//                                    .font(.caption)
//                            }
//                            .foregroundColor(.white)
//                        }
//                        Spacer()
//                        Button(action:{}){
//                            Circle()
//                                .fill(.red)
//                                .frame(width: 70,height: 70)
//                                .overlay{
//                                    Image(systemName: "xmark")
//                                        .imageScale(.large)
//                                        .foregroundColor(.white)
//                                }
//                        }
//
//                        Spacer()
//                        Button(action:{}){
//                            VStack(spacing:5){
//                                Image(systemName: "speaker.wave.2.fill")
//                                    .imageScale(.large)
//                                    .scaleEffect(1.1)
//
//                                Text("Speaker \noff")
//                                    .font(.caption)
//                            }
//                            .foregroundColor(.white)
//                        }
//                    }
//                    .padding(.horizontal)
                
            }

//        }
        
    }
}

//struct VoiceCallingView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoiceCallingView(data: dummyContentList[0])
//    }
//}
