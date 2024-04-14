//
//  GroupCallingAudioView.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 9/3/2024.
//

import SwiftUI
struct GroupCallingAudioView: View {
    //One prodcuer
    //Many Consumer
    var sessionId : String? = nil
    @StateObject private var ws = Websocket.shared
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject private var userVM : UserViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var cosnumerVM : SFUConsumersManager
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 3)
    @State private var messageToWebRTC : String = ""
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
            })
            
            VStack{
                Text(producerVM.room?.name ?? "--")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.vertical,5)
                
                ScrollView(.vertical,showsIndicators: false){
                    LazyVGrid(columns: self.columns){
                        renderProducerStreaming()
                        
                        ForEach(self.$cosnumerVM.connectedConsumerMap,id:\.uuid) { consumer in
                            ConsumerInfo(consumer: consumer)
                        }
                    }
                    
                }
              

                callingBtn()
            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
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
        VStack(spacing:0){
            AsyncImage(url: self.userVM.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                img
                    .resizable()
                    .aspectRatio( contentMode: .fill)
                    .frame(width: 35,height: 35)
                    .clipShape(Circle())
                
            }, placeholder: {
                ProgressView()
                    .frame(width: 35,height: 35)
            })
            .padding(.top,10)
            
            Text(self.userVM.profile?.name ?? "--")
                .foregroundStyle(.white)
                .font(.system(size: 12))
                .bold()
                .padding(.vertical,5)
            
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
//
//            Text(self.producerVM.callState == .Connected ? "Connected" : "Connecting...")
//                .font(.system(size: 8))
//                .bold()
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
            Button(action:{
                if self.producerVM.isAudioOn {
                    self.producerVM.mute()
                    self.updateMediaStatus(mediaType: SFUMediaType.Audio.rawValue, isOn: false)
                }else {
                    self.producerVM.unmute()
                    self.updateMediaStatus(mediaType: SFUMediaType.Audio.rawValue, isOn: true)
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.producerVM.isAudioOn ? "mic.slash.fill" : "mic.fill")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding()
                        .background{
                            Color.blue.clipShape(Circle())
                        }
                    
                    Text("Mute")
                        .font(.caption)
                        .foregroundStyle(.black)
                }
                .foregroundColor(.white)
            }
            Spacer()
            Button(action:{
                DispatchQueue.main.async {
                    //TODO: disconnect and reset and send the signal
                    onClose()
                    
                }
            }){
                Circle()
                    .fill(.red)
                    .frame(width: 70,height: 70)
                    .overlay{
                        Image(systemName: "phone.down.fill")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding(30)
                            .background{
                                Circle()
                                    .fill(.red)
                            }
                    }
            }
            
            Spacer()
            Button(action:{
                if self.producerVM.isSpeakerOn {
                    self.producerVM.speakerOff()
                    self.updateMediaStatus(mediaType: SFUMediaType.Speaker.rawValue, isOn: false)
                }else {
                    self.producerVM.speakerOn()
                    self.updateMediaStatus(mediaType: SFUMediaType.Speaker.rawValue, isOn: true)
                }
            }){
                VStack(spacing:5){
                    Image(systemName: self.producerVM.isSpeakerOn ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding()
                        .background{
                            Color.blue.clipShape(Circle())
                        }
                    
                    
                    Text("Speaker off")
                        .font(.caption)
                        .foregroundStyle(.black)
                }
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
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
                        .frame(width: 35,height: 35)
                        .clipShape(Circle())
                    
                }, placeholder: {
                    ProgressView()
                        .frame(width: 35,height: 35)
                })
                .padding(.top,10)
                
                Text(consumer.userInfo.producer_user_name)
                    .foregroundStyle(.white)
                    .font(.system(size: 12))
                    .bold()
                    .padding(.vertical,5)
                
                HStack{
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
