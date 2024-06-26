//
//  VoiceCallView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/5/2023.
//

import SwiftUI

//struct DotView: View {
//    @State var delay: Double = 0 // 1.
//    @State var scale: CGFloat = 0.5
//    var body: some View {
//        Circle()
//            .fill(.white)
//            .frame(width: 5, height: 5)
//            .scaleEffect(scale)
//            .transition(.scale)
//            .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(delay)) // 2.
//            .onAppear {
//                withAnimation {
//                    self.scale = 1
//                }
//            }
//    }
//}

struct VoiceCallView: View {
    let name : String
    let path : URL
    @StateObject private var hub = BenHubState.shared
    @State private var counter : Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @EnvironmentObject private var videoCallVM : RTCViewModel
    @EnvironmentObject private var userVM : UserViewModel
    
    var body: some View {
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
                    .overlay(alignment:.top){
                        VStack(spacing:12){
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
                            
                            if self.videoCallVM.callState == .Connected {
                                //TODO Start a timer
                                Text(timeString(time: TimeInterval(self.counter)))
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }else {
                                
                                
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
                            
                            Spacer()

            //
                            if self.videoCallVM.callState == .Incoming {
                                self.IncomingCall()
                            }else {
                                self.Connected()
                            }
                        }
                        .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                        .padding(.bottom)
                        .padding(.horizontal)
                        .background{
                            ZStack{
                                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: true, isVoice: true,refershTrack: self.$videoCallVM.refershLocalTrack).frame(width: 0, height: 0)
                              
                                RTCVideoView(webClient: videoCallVM.webRTCClient, isRemote: false, isVoice: true,refershTrack: self.$videoCallVM.refershRemoteTrack).frame(width: 0, height: 0)
                              
                            }
                            .hidden()
                        }.onReceive(self.timer){ _ in
                            if self.videoCallVM.callState != .Connected {
                                return
                            }
                            self.counter += 1
                        }
                        .onChange(of: self.videoCallVM.callState){ state in
                            if state == .Ended { //TODO: the connection is disconnected -> Reset all the and disconnect
                                SoundManager.shared.stopPlaying()
                                withAnimation{
                                    self.videoCallVM.isIncomingCall = false
                                }
                                self.videoCallVM.DisConnect()
                                playEndCallSoundEffect()
                            
                            }
                        }
                    }
                
            }, placeholder: {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            })
        }
        .overlay(alignment: .top){
        
            HStack{
                Button(action:{
                    withAnimation(){
//                                        self.videoCallVM.isIncomingCall = false
                        self.videoCallVM.isMinimized = true
                    }
                }){
                    Image(systemName: "chevron.down")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .scaleEffect(1.3)
                }
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .padding(.horizontal)
//            .padding()
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        .animation(.linear)
        
    }
    
    private func playEndCallSoundEffect(){
        guard let url = Bundle.main.url(forResource: "endcall", withExtension: ".mp3") else {
            return
        }
        SoundManager.shared.playSound(url: url,repeatTime: 0)
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
//                        SoundManager.shared.stopPlaying()
//                        playEndCallSoundEffect()
                        
                        self.sendCallingMessage(message: "Ended the voice call.")
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
        .padding(.horizontal,20)
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func Connected() -> some View {
        HStack{
            Button(action:{
                if self.videoCallVM.isAudioOn {
                    self.videoCallVM.mute()
                }else {
                    self.videoCallVM.unmute()
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.videoCallVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                        .imageScale(.large)
                        .scaleEffect(1.1)
                    
                    Text("Mute")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            Spacer()
            Button(action:{
                DispatchQueue.main.async {
                    //TODO: disconnect and reset and send the signal
                    self.videoCallVM.sendDisconnect()
                    self.videoCallVM.DisConnect()
                    withAnimation{
                        self.videoCallVM.isIncomingCall = false
                    }
                    self.sendCallingMessage(message: "Ended the voice call.")
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
            
            Spacer()
            Button(action:{
                if self.videoCallVM.isSpeakerOn {
                    self.videoCallVM.speakerOff()
                }else {
                    self.videoCallVM.speakerOn()
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.videoCallVM.isSpeakerOn ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .imageScale(.large)
                        .scaleEffect(1.1)
                    
                    Text("Speaker \noff")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
    
    func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60
        
        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    
    private func sendCallingMessage(message : String){
        if message.isEmpty {
            return
        }
        
        guard let toUserId = self.videoCallVM.toUserUUID else{
            print("userId is empty")
            return
        }
        
        let msgID = UUID().uuidString
        
        let msg = WSMessage(
            messageID:msgID,
            replyMessageID: nil,
            avatar: self.userVM.profile!.avatar,
            fromUserName: self.userVM.profile!.name,
            fromUUID: self.userVM.profile!.uuid,
            toUUID: toUserId,
            content: message,
            contentType: ContentType.TEXT.rawValue,
            eventType: EventType.MESSAGE.rawValue,
            messageType: MessageType.Signal.rawValue,
            urlPath: nil,
            fileName: nil,
            fileSize: nil,
            contentAvailableTime: nil,
            contentUUID: nil,
            contentUserName: nil,
            contentUserAvatar: nil,
            contentUserUUID: nil)
        Websocket.shared.handleMessage(event:.send,msg: msg)
        
        
        Task {
            await Websocket.shared.checkMessage(messageID: msgID)
        }
    }

}



extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    return formatter.string(from: self) ?? ""
  }
}
