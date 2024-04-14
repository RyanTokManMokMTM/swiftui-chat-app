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

    @StateObject private var ws = Websocket.shared
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var cosnumerVM : SFUConsumersManager
    @State private var messageToWebRTC : String = ""
    let columns = Array(repeating: GridItem(spacing: 10, alignment: .center), count: 2)
   
    var body: some View {
        ZStack(alignment: .top) {
            AsyncImage(url: producerVM.room?.AvatarURL ?? URL(string: ""), content: {img in
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
                    .background(Color.black)
            })
            
            VStack{
                Text(producerVM.room?.name ?? "--")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.vertical,5)
                
                ScrollView(.vertical,showsIndicators: false){
                    LazyVGrid(columns: self.columns,spacing: 5){
                        renderProducerStreaming()
                        ForEach($cosnumerVM.connectedConsumerMap,id :\.uuid) { consumer in
                            ConsumerVideoInfo(consumer: consumer)
                                .padding(.horizontal,5)
                        }
                    }
                }
                callingBtn()
            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .padding(.bottom)
            .padding(.horizontal)
        }
        .alert(isAlert: $hub.isPresented){
            switch hub.type{
            case .normal,.system:
                BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
            case .messge:
                BenHubAlertWithMessage( message: hub.message,info: hub.info!)
            }
        }


    }
    
   
    @ViewBuilder
    private func renderProducerStreaming() -> some View {
    
        RTCVideoView(webClient: self.producerVM.webRTCClient, isRemote: false, isVoice: false,refershTrack: Binding<Bool>(get: {return self.producerVM.refershLocalTrack},
                                                                                                                                              set: { p in self.producerVM.refershLocalTrack = p}))
        .frame(width: 180,height: 250)
        .clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners]))
        .background(Color.black.clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
        .overlay(alignment:  self.producerVM.webRTCClient?.VideoIsEnable == true ? .bottomLeading : .center ){
            if self.producerVM.webRTCClient?.VideoIsEnable != true   {
                VStack(spacing:5){
                    AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                        img
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: 80,height: 80)
                            .clipShape(Circle())
                        
                    }, placeholder: {
                        ProgressView()
                            .frame(width: 50,height: 50)
                    })
                    .padding(.vertical,5)
                    
                    Text(self.userVM.profile?.name ?? "--")
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .bold()
                    
                    HStack{
                        if !self.producerVM.isSpeakerOn {
                            Image(systemName: "speaker.slash")
                                .imageScale(.small)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.vertical,5)
                        }
                        
                        if !self.producerVM.isAudioOn {
                            Image(systemName:  "mic.slash.fill")
                                .imageScale(.small)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.horizontal,5)
                        }
                    }
                }
            }else {
                HStack(spacing:5){
                    AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                        img
                            .resizable()
                            .aspectRatio( contentMode: .fill)
                            .frame(width: 30,height: 30)
                            .clipShape(Circle())
                        
                    }, placeholder: {
                        ProgressView()
                            .frame(width: 30,height:30)
                    })
                    .padding(.vertical,5)
                    .padding(.horizontal,3)
                    
                    Text(self.userVM.profile?.name ?? "--")
                        .foregroundColor(.white)
                        .font(.system(size: 10))
                        .bold()
                        .padding(.vertical,5)
                    
                    
                    if !self.producerVM.isSpeakerOn {
                        Image(systemName: "speaker.slash")
                            .imageScale(.small)
                            .foregroundColor(.white)
                            .padding(5)
                            .background{
                                BlurView().clipShape(Circle())
                            }
                            .padding(.vertical,5)
                    }
                    
                    if !self.producerVM.isAudioOn {
                        Image(systemName:  "mic.slash.fill")
                            .imageScale(.small)
                            .foregroundColor(.white)
                            .padding(5)
                            .background{
                                BlurView().clipShape(Circle())
                            }
                            .padding(.horizontal,5)
                    }
                }.padding(.horizontal,8)
            }
           
        }
    
    }
    
    
    private func onClose(){
        self.producerVM.sendDisconnect()
        self.producerVM.DisConnect()
        self.producerVM.isIncomingCall = false
        self.cosnumerVM.closeAllConsumer()
    }
    
    private func updateMediaStatus(mediaType: String,isOn : Bool) {
        guard let sessionId = self.producerVM.sessionId else {
            print("sesson id is nil")
            return
        }
        
        guard let clientId = self.userVM.profile?.uuid else{
            print("clientId id is nil")
            return
        }
        Websocket.shared.sendUpdateMediaStatus(sessionId: sessionId, clientId: clientId, mediaType: mediaType, isOn: isOn)
    }
    
    @ViewBuilder
    private func callingBtn() -> some View {
        HStack{
            Button(action: {
                if self.producerVM.isAudioOn {
                    self.producerVM.mute()
                    self.updateMediaStatus(mediaType: SFUMediaType.Audio.rawValue, isOn: false)
                }else {
                    self.producerVM.unmute()
                    self.updateMediaStatus(mediaType: SFUMediaType.Audio.rawValue, isOn: true)
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
                    self.updateMediaStatus(mediaType: SFUMediaType.Speaker.rawValue, isOn: false)
                }else {
                    self.producerVM.speakerOn()
                    self.updateMediaStatus(mediaType: SFUMediaType.Speaker.rawValue, isOn: true)
                }
            }){
                Image(systemName: self.producerVM.isSpeakerOn ? "speaker.slash" :  "speaker.wave.1.fill")
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
                    self.updateMediaStatus(mediaType: SFUMediaType.Video.rawValue, isOn: false)
                }else {
                    self.producerVM.videoOn()
                    self.updateMediaStatus(mediaType: SFUMediaType.Video.rawValue, isOn: true)
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
    @Binding var consumer : SFUConsumer
    var body: some View {
        RTCVideoView(webClient: consumer.webRTCClient, isRemote: true, isVoice: false,
                     refershTrack: $consumer.refershRemoteTrack)

            .frame(width: 180,height: 250)
            .clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners]))
            .background(Color.black.clipShape(CustomConer(width: 10, height: 10,coners: [.allCorners])))
            .overlay(alignment: consumer.webRTCClient?.remoteVIdeoTrack != nil && consumer.isVideoOn ? .bottomLeading : .center ){
                if  consumer.webRTCClient?.remoteVIdeoTrack != nil && consumer.isVideoOn {
                    HStack(spacing:5){
                        AsyncImage(url: consumer.userInfo.AvatarURL, content: { img in
                            img
                                .resizable()
                                .aspectRatio( contentMode: .fill)
                                .frame(width: 30,height: 30)
                                .clipShape(Circle())
                            
                        }, placeholder: {
                            ProgressView()
                                .frame(width: 30,height: 30)
                        })
                        .padding(.vertical,5)
                        .padding(.horizontal,3)
                        
                        Text(consumer.userInfo.producer_user_name)
                            .foregroundColor(.white)
                            .font(.system(size: 10))
                            .bold()
                            .padding(.vertical,5)
                        
                        if !consumer.isSpeakerOn {
                            Image(systemName: "speaker.slash")
                                .imageScale(.small)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.vertical,5)
                        }
                        
                        if !consumer.isAudioOn {
                            Image(systemName:  "mic.slash.fill")
                                .imageScale(.small)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .padding(.horizontal,5)
                        }

                    }
                }else {
                    VStack(spacing:5){
                        AsyncImage(url: consumer.userInfo.AvatarURL, content: { img in
                            img
                                .resizable()
                                .aspectRatio( contentMode: .fill)
                                .frame(width: 80,height: 80)
                                .clipShape(Circle())
                            
                        }, placeholder: {
                            ProgressView()
                                .frame(width: 80,height: 80)
                        })
                        .padding(.vertical,5)
                        .padding(.horizontal,3)
                        
                        Text(consumer.userInfo.producer_user_name)
                            .foregroundColor(.white)
                            .font(.system(size: 10))
                            .bold()
                        
                        HStack{
                            if !consumer.isSpeakerOn {
                                Image(systemName: "speaker.slash")
                                    .imageScale(.small)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background{
                                        BlurView().clipShape(Circle())
                                    }
                                    .padding(.vertical,5)
                            }
                            
                            if !consumer.isAudioOn {
                                Image(systemName:  "mic.slash.fill")
                                    .imageScale(.small)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background{
                                        BlurView().clipShape(Circle())
                                    }
                                    .padding(.horizontal,5)
                            }

                        }
                    
                    }
                   
                }
                
            }
    }
}
