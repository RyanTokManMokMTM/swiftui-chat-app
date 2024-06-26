//
//  VideoCall.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 14/5/2023.
//

import SwiftUI

struct VideoCallView: View {
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject var videoCallVM : RTCViewModel
    let name : String
    let path : URL
    var body: some View {
        ZStack{

            AsyncImage(url: path, content: {img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(){
                        BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all)
                    }
                    .overlay(alignment:.top){
                        if self.videoCallVM.callState == .Incoming {
                            incomingCallView()
                        }else {
                            videoCallingView()
                        }
                    
                    }
                
            }, placeholder: {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            })


        }
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        .animation(.linear)
        .edgesIgnoringSafeArea(.all)
        .overlay(alignment: .top){
            HStack{
                Button(action:{
                    withAnimation(){
                        self.videoCallVM.isMinimized = true
                    }
                }){
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .scaleEffect(1.3)
                }
                .padding(10)
                .background(BlurView().clipShape(Circle()))

                Spacer()
//
                if self.videoCallVM.callState == .Connected {
                    VStack{
                        AsyncImage(url: path, content: {img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:30,height: 30)
                                .clipShape(Circle())



                        }, placeholder: {
                            ProgressView()
                                .frame(width:120,height: 120)

                        })

                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .padding(.horizontal)
//            .padding()
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)

        }
        .onChange(of: self.videoCallVM.callState){ state in
            if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
                DispatchQueue.main.async {
                    SoundManager.shared.stopPlaying()
                    self.videoCallVM.isIncomingCall = false
                    self.videoCallVM.DisConnect()
                    hub.AlertMessage(sysImg: "", message: "Video Call Ended")
                    playEndCallSoundEffect()
                }
            }
        }

    }
    private func playEndCallSoundEffect(){
        guard let url = Bundle.main.url(forResource: "endcall", withExtension: ".mp3") else {
            return
        }
        SoundManager.shared.playSound(url: url,repeatTime: 0)
    }
    
    @ViewBuilder
    private func videoCallingView() -> some View {
        VStack{
            RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: true, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershRemoteTrack},
                                                                                                                                                                  set: { p in self.videoCallVM.refershRemoteTrack = p}))
            //            .edgesIgnoringSafeArea(.all)

            .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            .background{
                if self.videoCallVM.callState != .Connected{
                    ZStack{
                        AsyncImage(url: path, content: {img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                                .edgesIgnoringSafeArea(.all)
                                .overlay{
                                    BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all)
                                }

                        }, placeholder: {
                            ProgressView()
                                .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                        })
                        BlurView().edgesIgnoringSafeArea(.all)
                    }
                    .overlay(alignment:.top){
                        VStack{
                            AsyncImage(url: path, content: {img in
                                img
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:120,height: 120)
                                    .clipShape(Circle())



                            }, placeholder: {
                                ProgressView()
                                    .frame(width:120,height: 120)

                            })

                            Text(name)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            HStack(spacing:5){
                                Image(systemName: "phone.badge.waveform")
                                    .imageScale(.medium)
                                    .padding(.horizontal,5)
                                    .foregroundColor(.white)
                                Text("Waiting for response...")
                                    .foregroundColor(.white)
                                    .font(.footnote)
                            }
                            .padding(.vertical,5)

                        }
                        .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                        .padding()
                    }
                    
                }

            }

            
        }
        .overlay(alignment:.bottomLeading){
            VStack(alignment:.trailing){
                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: false, isVoice: false,refershTrack: Binding<Bool>(get: {return self.videoCallVM.refershLocalTrack},
                                                                                                                                                      set: { p in self.videoCallVM.refershLocalTrack = p}))
                .frame(width: 150, height: 220)
                .cornerRadius(25)
                .padding()
                .background(BlurView().cornerRadius(25).padding())
                callingBtn()
            }
            .padding(.bottom,30)
           
        }
        
    }
    
    @ViewBuilder
    private func callingBtn() -> some View {
        HStack{
            Button(action: {
                if self.videoCallVM.isAudioOn {
                    self.videoCallVM.mute()
                }else {
                    self.videoCallVM.unmute()
                }
            }){
                Image(systemName: self.videoCallVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }
           
            }
            Spacer()
            Button(action: {
                if self.videoCallVM.isSpeakerOn {
                    self.videoCallVM.speakerOff()
                }else {
                    self.videoCallVM.speakerOn()
                }
            }){
                Image(systemName: self.videoCallVM.isSpeakerOn ? "speaker.slash" :  "speaker.wave.3.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                DispatchQueue.main.async {
                    //TODO: disconnect and reset and send the signal
                    self.videoCallVM.sendDisconnect()
                    self.videoCallVM.DisConnect()
                    self.videoCallVM.isIncomingCall = false
                }
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
                if self.videoCallVM.isVideoOn {
                    self.videoCallVM.videoOff()
                }else {
                    self.videoCallVM.videoOn()
                }
            }){
                Image(systemName: self.videoCallVM.isVideoOn ? "video.slash" : "video.fill")
                    .imageScale(.large)
                    .foregroundColor(.white)
                    .padding()
                    .background{
                        Color.blue.clipShape(Circle())
                    }

            }
            Spacer()
            Button(action: {
                self.videoCallVM.changeCamera()
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
    
    @ViewBuilder
    private func incomingCallView() -> some View {
        VStack{
            VStack{
                
                AsyncImage(url: path, content: {img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:120,height: 120)
                        .clipShape(Circle())
                    
                    
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width:120,height: 120)
                    
                })
                
                Text(name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                HStack(spacing:5){
                    Image(systemName: "phone.badge.waveform")
                        .imageScale(.medium)
                        .padding(.horizontal,5)
                        .foregroundColor(.white)
                    Text("Waiting for response")
                        .foregroundColor(.white)
                        .font(.footnote)
                    
                }
                .padding(.vertical,5)
                

            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()

            
            VStack{
                Spacer()
                IncomingCall()
            }
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .padding(.horizontal)
        }
        .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
//        .edgesIgnoringSafeArea(.all)
    }
    
    
    
    @ViewBuilder
    private func IncomingCall() -> some View {
        HStack{
//            Spacer()
            VStack{
                Button(action:{
                    //TODO: Send answer
                    self.videoCallVM.callState = .Connecting
                    self.videoCallVM.sendAnswer(type: .Voice)
                }){
                    Circle()
                        .fill(.green)
                        .frame(width: 70,height: 70)
                        .overlay{
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                }
                
                Text("Accept")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            Spacer()
            
            VStack{
                Button(action:{
                    //Send a Bye signal
                    DispatchQueue.main.async { //TODO: Send disconnected signal and Disconnect and reset all RTC
                        self.videoCallVM.sendDisconnect()
                        self.videoCallVM.DisConnect()
                        self.videoCallVM.isIncomingCall = false
                    }
                 
                }){
                    Circle()
                        .fill(.red)
                        .frame(width: 70,height: 70)
                        .overlay{
                            Image(systemName: "phone.down.fill")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                }
                Text("Reject")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)


//            Spacer()
        }
    }
  
}
//
//struct VideoCall_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoCall(name: "Testing", path: URL(string: RESOURCES_HOST + "/default.jpg")!)
//    }
//}
