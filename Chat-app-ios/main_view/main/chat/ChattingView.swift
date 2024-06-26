//
//  ChattingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/2/2023.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AVKit
import AVFoundation

enum MediaType : String {
    case Image = "image"
    case Video = "video"
}

private struct OffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

struct ChattingView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @EnvironmentObject private var videoCallVM : RTCViewModel
    @EnvironmentObject private var sfuProducerVM : SFProducerViewModel
    @EnvironmentObject private var sfuConsumerVM : SFUConsumersManager
    
    let chatUserData : ActiveRooms
    @Binding var messages : [RoomMessages]
    @StateObject private var hub = BenHubState.shared
    
    @State private var text : String = ""
    @FocusState private var isFocus : Bool
    @State private var messageIndex : Int = 0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData : Data? = nil
    @State private var isShowImage : Bool = false
    @State private var showImageURL : String = ""
    @State private var showPicker = false
    
    @State private var isShowInfo : Bool = false
    @State private var isPlayAudio : Bool = false
    @State private var isShowVideo : Bool = false

    @State private var audioInfo : RoomMessages?
    @State private var videoURL : URL?
    
    @State private var isFileExport : Bool = false
    @State private var fileExportURL : URL? = nil
    
    @State private var isFetchMore: Bool = false
    @State private var isShowMessage = false
    
    @State private var isVoiceChat : Bool = false
    @State private var isUseSticket : Bool = false
    @State private var isShowMoreContent : Bool = false
    @State private var isReplyMessage : Bool = false
    @State private var replyMessage : RoomMessages?
    @State private var placeHolder : String  = "Message"
    
    @State private var isShowStoryViewer : Bool = false
    @State private var toShowStoryId : String? = nil
    @State private var isGettingStoryInfo : Bool = false
    @State private var friendUUID : String = ""
    
    @State private var selectStickerGroupId : String? = nil
    @State private var isShowStickerInfo : Bool = false
    
    var body: some View {
        VStack{
            chatView()
        }
        .onDisappear{
            self.UDM.currentRoom = nil
            self.UDM.currentRoomMessage.removeAll()
            self.UDM.previousTotalMessage = 0
            self.videoCallVM.toUserUUID = nil
        }
        .sheet(isPresented: $isShowStickerInfo){
            if let stickerId = self.selectStickerGroupId {
                StickerInfoBottomSheetView(stickerId: stickerId)
                    .presentationDetents([.fraction(0.3)])
                    .environmentObject(self.userModel)
            }
        }
        .fullScreenCover(isPresented: $isShowStoryViewer){
            if let storyUUID = self.toShowStoryId {
                StoryViewer(isShowStoryViewer:$isShowStoryViewer,storyId: storyUUID, friendUUID: self.friendUUID)
            }
        }
        .fullScreenCover(isPresented: $isPlayAudio){
            AudioPlayerView(isPlayingAudio: $isPlayAudio,fileName: self.audioInfo!.file_name!, path: self.audioInfo!.FileURL)
        }
        .fullScreenCover(isPresented: $isShowVideo){
            VideoPlayerView(isShowVideoPlayer: $isShowVideo, url: self.videoURL!)
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                if self.chatUserData.message_type == 1 {
                    NavigationLink(destination: OtherUserProfileView(uuid: self.chatUserData.id!.uuidString, isShowDetail: $isShowInfo)){
                        HStack(){
                            Text(self.chatUserData.name ?? "UNKNOW CHAT")
                                .bold()
                                .font(.system(size: 15))
                                .foregroundColor(.black)
//                                .onTapGesture{
//                                    withAnimation{
//                                        self.isShowInfo = true
//                                    }
//                                }
                            Spacer()
                        }
                        .padding(.horizontal,5)
                    }
                }else {
                    NavigationLink(
                        destination:
                                    GroupProfileView(uuid: self.chatUserData.id!.uuidString, isShowDetail: $isShowInfo)
                        .environmentObject(userModel)
                    ){
                        HStack(){
                            Text(self.chatUserData.name ?? "UNKNOW CHAT")
                                .bold()
                                .font(.system(size: 15))
                                .foregroundColor(.black)
//                                .onTapGesture{
//                                    withAnimation{
//                                        self.isShowInfo = true
//                                    }
//                                }
                            Spacer()
                        }
                        .padding(.horizontal,5)
                    }
                }
               
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                if chatUserData.message_type == 1{
                    HStack{
                        Button(action:{
                            DispatchQueue.main.async {
                                setUpReceiverInfo()
                                setUpVoiceCallingInfo()
                            }

                        }){
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                        
                        Button(action:{
                            DispatchQueue.main.async {
                                setUpReceiverInfo()
                                setUpVideoCallingInfo()
                            }

                        }){
                            Image(systemName: "video.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                    }
                }else{
                    HStack{
                        Button(action:{
                            DispatchQueue.main.async {
                                setUpVoiceCallingInfoForGroup()
//                                setUpVoiceCallingInfo()
                            }

                        }){
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                        Button(action:{
                            DispatchQueue.main.async {
                                setUpVideoCallingForGroup()
                            }

                        }){
                            Image(systemName: "video.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                    }
                }
                
                
                

            }
        }
        .onChange(of: self.selectedItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.selectedData = data
                    
                   
                    let fileFormat = data.fileExtension
                    let fileName = UUID().uuidString + "." + fileFormat
                    Task.init{
                        await self.sendFile(data:data,fileName:fileName,fileSize: 0,ext:fileFormat,type:isVideo(ext:fileFormat) ? .VIDEO : .IMAGE)
                    }
                }
            }
        }
        .fileExporter(isPresented: $isFileExport, document: Doc(url: self.fileExportURL), contentType: .data) { result in
            switch result {
            case .success(let url):
                hub.isWaiting = false
                hub.AlertMessage(sysImg: "checkmark", message: "saved file")
            case .failure(let error):
                print(error.localizedDescription)
                hub.AlertMessage(sysImg: "xmark", message: error.localizedDescription)
            }
        }
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.data,.pdf,.text,.mp3,]) { result in
            switch result {
            case .success(let data):
                do {
                    let fileData = try Data(contentsOf: data)
                    let fileSize = data.filesize ?? 0
                    let fileName = data.lastPathComponent

                    let ext = data.pathExtension
                    Task.init{
                        await self.sendFile(data: fileData, fileName: fileName, fileSize: Int64(fileSize), ext: ext, type: isAudio(ext : ext) ? .AUDIO : .FILE)
                    }
                } catch(let err){
                    print("conver file to data failed \(err.localizedDescription)")
                }
                
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        .fullScreenCover(isPresented: $isShowImage){
            ShowImageView(imageURL: self.showImageURL, isShowImage: $isShowImage)
                
        }
    }
    
    
    @ViewBuilder
    private func chatView() -> some View{
        ScrollViewReader { scroll in
               ScrollView(.vertical){
                   GeometryReader { proxy in
                       Color.clear.preference(
                           key: OffsetPreferenceKey.self,
                           value: proxy.frame(
                               in: .named("ScrollViewOrigin")
                           ).origin
                       )
                   }
                   .frame(width: 0, height: 0)
                    VStack{
                        if self.isFetchMore{
                            ProgressView()
                                .onAppear{
                                    UDM.fetchCurrentRoomMessage()
                                }
                        }
                        
                        ForEach(messages.indices,id :\.self) { index in
                            VStack(spacing:0){

                                
                                if messages[index].content_type == ContentType.SYS.rawValue{
                                    SysContentTypeView(message: messages[index])
                                }else {
                                    
                                    ChatBubble(direction: isOwner(id : messages[index].sender!.id!.uuidString.lowercased()) ? .sender : .receiver,messageType: Int(chatUserData.message_type), userName: messages[index].sender!.name!, userAvatarURL: messages[index].sender!.AvatarURL, contentType: messages[index].content_type! ,messageStatus: messages[index].messageStatus,sentTime: messages[index].sent_at,isReplyMessage:$isReplyMessage,replyMessage:$replyMessage,message : messages[index]){
                                        content(message: messages[index])
                                        
                                    }
                                    .transition(.move(edge:  isOwner(id : messages[index].sender!.id!.uuidString.lowercased()) ? .trailing :.leading))
                                }
                            }
                            .id(index)
                        }
                        .overlay{
                            Color.white.opacity(self.isShowMessage ? 0 : 1)
                        }
                        .onAppear(){
                            DispatchQueue.main.async{
                                withAnimation{
                                    scroll.scrollTo(messages.count - 1)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if !self.isShowMessage {
                                        self.isShowMessage = true
                                    }
                                }
                            }
                            self.isFetchMore = false

                        }

                        .onChange(of: messages.count){ _ in
                            if !self.isFetchMore {
                                withAnimation{
                                    scroll.scrollTo(messages.count - 1)
                                }
                            }else {
                                self.isFetchMore  = false
                            }
                            
                            
                        }
                    }
                }
              
               .coordinateSpace(name: "ScrollViewOrigin")
                .onPreferenceChange(OffsetPreferenceKey.self,
                                    perform: { point in
                
                    if !isFetchMore && point.y > 100 && UserDataModel.shared.hasMoreMessage() {
                        withAnimation{
                            isFetchMore = true
                        }
                    }
                })

            InputField()
        }
        
    }
    
    private func setUpReceiverInfo(){
        self.videoCallVM.toUserUUID = self.chatUserData.id!.uuidString.lowercased()
        self.videoCallVM.userName = self.chatUserData.name!
        self.videoCallVM.userAvatar = self.chatUserData.avatar!
    }
    
    private func setUpVoiceCallingInfo(){
        self.videoCallVM.start(type: .Voice,room: self.chatUserData) //TODO: creating a new peer if it don't init and setting RTC device
        self.videoCallVM.voicePrepare() //TODO: To disable video
        self.videoCallVM.callState = .Connecting //TODO: Current status is connecting
        withAnimation{
            self.videoCallVM.isIncomingCall = true //TODO: show the view
//            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
        }
        
        //Sending the offer
        self.videoCallVM.sendOffer(type:.Voice) //TODO: sending offer to receiver
        
        //Sending an set message -> Start a xxx call.
        self.sendCallingMessage(message: "Stated a voice call.")
    }
    
    private func setUpVideoCallingInfo(){
        self.videoCallVM.start(type: .Video,room: self.chatUserData) //TODO: creating a new peer if it don't init and setting RTC device
        self.videoCallVM.videoPrepare() //TODO: To enable video
        self.videoCallVM.callState = .Connecting //TODO: Current status is connecting
        withAnimation{
            self.videoCallVM.isIncomingCall = true //TODO: show the view
        }
        //Sending the offer
        self.videoCallVM.sendOffer(type:.Video) //TODO: sending offer to receiver
        self.sendCallingMessage(message: "Stated a video call.")
    }
    
    private func isAudio(ext : String) -> Bool {
        return ext == "mp3" || ext == "wav" || ext == "m3u" || ext == "m4a"
    }
    
    private func isVideo(ext : String) -> Bool {
        return ext == "mp4"
    }

    
    @ViewBuilder
    private func commentContextMenu(message : RoomMessages) -> some View {
        if let id = message.sender?.id?.uuidString.lowercased()  {
            
            let isSender = isOwner(id: id)
            if !isSender {
                Button {
                    DispatchQueue.main.async {
                        withAnimation{
                            self.isReplyMessage = true
                            self.replyMessage = message
                        }
                    }
                } label: {
                    Text("Reply")
                }
            }else if isSender {
                
                Button {
                    DispatchQueue.main.async {
                        withAnimation{
                            self.isReplyMessage = true
                            self.replyMessage = message
                        }
                    }
                } label: {
                    Text("Reply")
                }

                Button {
                    let sendSystemMessage = "\(message.sender?.name ?? "UNKNOW") recalled a message."
                    let systemMessage = "You recalled a message."
                    UserDataModel.shared.deleteMessage(msg: message, content: systemMessage)

                    DispatchQueue.main.async {
                   
                        //MARK: removed the message from cache and send a message to all user
                        //send a signal to other for recall the message
                        Websocket.shared.recallMessage(message: message, toUUID: self.chatUserData.id!.uuidString.lowercased(), messageType: self.chatUserData.message_type,sendMessage: sendSystemMessage)

                    }
                } label: {
                    Text("Recall")
                }

            }

            if message.messageStatus == .notAck {
                Button {
                    print("resent")
                } label: {
                    Text("Resend")
                }
            }
        }
    }
    
    @ViewBuilder
    private func content(message : RoomMessages) -> some View{
        if message.content_type == ContentType.TEXT.rawValue {
            TextContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                }
                
        }else if message.content_type == ContentType.IMAGE.rawValue{
            ImageContentTypeView(message:message)
                .contextMenu{
                    commentContextMenu(message: message)
                }
                
        }else if message.content_type == ContentType.FILE.rawValue{
            FileContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                    Button("Save to file disk",action:{
                        Task {
                            await self.downloadAndSave(message:message)
                        }
                    })
                    .disabled(message.tempData != nil)
                }
        }else if message.content_type == ContentType.AUDIO.rawValue {
            AudioContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                    Button("Save to file disk",action:{
                        Task {
                            await self.downloadAndSave(message:message)
                        }
                    })
                    .disabled(message.tempData != nil)
                }
        } else if message.content_type == ContentType.VIDEO.rawValue {
            VideoContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                    Button("Save to album"){
                        hub.SetWait(message: "Downloading and saving...")
                        Task {
                            
                            let resp = await ChatAppService.shared.DownloadTaskFile(fileURL: message.FileURL)
                            hub.isWaiting = false
                            switch resp {
                            case .success(let fileURL):
                                do {
                                    let documentsURL = try
                                    FileManager.default.url(for: .picturesDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true)
                                    
                                    let savedURL = documentsURL.appendingPathComponent(message.file_name!)
                                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savedURL)
                                    }) { saved, error in
                                        if saved {
                                            hub.AlertMessage(sysImg: "checkmark", message: "Saved successfully.")
                                        }
                                    }
                                }catch (let err){
                                    //                                print(err.localizedDescription)
                                    hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
                                }
                                
                            case .failure(let err):
                                print(err.localizedDescription)
                                hub.AlertMessage(sysImg: "exclamationmark.circle", message: err.localizedDescription)
                            }
                            
                        }
                    }
                }
            
        }else if message.content_type == ContentType.STORY.rawValue {
            StoryContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                }
        } else if message.content_type == ContentType.REPLY.rawValue {
            replyMessageContentTypeView(message: message)
                .contextMenu{
                    commentContextMenu(message: message)
                }
        } else if message.content_type == ContentType.STICKER.rawValue {
            StickerContentTypeView(message: message)
 
        } else if message.content_type == ContentType.SHARED.rawValue {
            StoryShareContentTypeView(message:message)
                .contextMenu{
                    commentContextMenu(message: message)
                }
        }
    }
    
    
    @ViewBuilder
    func InputField() -> some View{
        VStack{
            if self.isReplyMessage {
                HStack{
                    Text(replyMessageContent())
                        .font(.system(size: 10))
                        .padding(5)
                        .lineLimit(1)
                    Spacer()
                    
                    Button(action:{
                        DispatchQueue.main.async {
                            withAnimation{
                                self.isReplyMessage = false
                                self.replyMessage = nil
                            }
                           
                        }
                    }){
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                    }
                    .padding(5)
                }
                .background(BlurView(style: .systemChromeMaterialLight).cornerRadius(10))
                
            }
            HStack{

            
                VStack(alignment:.leading){

                        TextField(placeHolder,text:$text)
                            .padding(.horizontal)
                            .frame(height:37)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                            .focused($isFocus)
                            .submitLabel(.send)
                            .onSubmit{
                                //                        sendMessage()
                                if self.isReplyMessage {
                                    sendReplyMessage()
                                }else {
                                    sendMessage()
                                }
                                self.messageIndex = messages.count - 1
                            }
                        
//                    }
                   
                }
                
                Button(action:{
                    withAnimation{
                        if self.isShowMoreContent  {
                            self.isShowMoreContent = false
                        }
                        
                        if self.isUseSticket {
                            self.isUseSticket = false
                            self.isFocus = true
                        }else {
                            self.isUseSticket = true
                            self.isFocus = false
                        }
                        
                    }
                }){
                    Image(systemName: self.isUseSticket ? "keyboard" :"face.smiling")
                        .imageScale(.large)
                        .foregroundColor( .blue)
                }
                
                Button(action:{
                    withAnimation{
//                        self.showPicker.toggle()
                        if isShowMoreContent {
                            self.isShowMoreContent = false
                           
                        }else {
                            
                            self.isUseSticket = false
                            self.isFocus = false
                            self.isShowMoreContent = true
                        }
                      
                    }
                }){
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .foregroundColor( .blue)
                }

            }
            
            if self.isUseSticket {
                StickerView(onSend: self.onSendSticker(stickerUri:StickerUUID:))
            }
            
            if self.isShowMoreContent{
                AddContentView(content: {
                    Group{
                        moreContentCell(sysName: "doc.circle", cellName: "File"){
                            withAnimation{
                                self.showPicker = true
                            }
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images]),photoLibrary: .shared()){
                            VStack(spacing:10){
                                Image(systemName: "photo.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                Text("Image")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .any(of: [.videos]),photoLibrary: .shared()){
                            VStack(spacing:10){
                                Image(systemName: "video.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                Text("Video")
                                    .foregroundColor(.black)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                            }
                        }
//
                    }
                })
            }
        }
        .padding(8)
        .background(.thickMaterial)
        .onChange(of: self.isReplyMessage){ state in
            if state {
                self.placeHolder = "@\(self.replyMessage?.sender?.name ?? "UNKNOW")"
            }else {
                self.placeHolder = "Message"
            }
        }
        .onChange(of: self.isFocus) { state in
            if state  {
                self.isUseSticket = false
            }
        }
    }
    
    private func playMessageSentSound(){
        AudioServicesPlayAlertSound(MESSAGE_SENT_SOUND_ID)
    }
    
    private func replyMessageContent() -> String {
        guard let replyMsg = self.replyMessage else {
            return ""
        }
        var message : String = "\(replyMsg.sender?.name ?? "") : "

        switch replyMsg.content_type {
        case ContentType.TEXT.rawValue, ContentType.REPLY.rawValue:
            message.append(replyMsg.content ?? "")
            break
        case ContentType.IMAGE.rawValue:
            message.append("[ image content ]")
            break
        case ContentType.FILE.rawValue:
            message.append("[ file content ]")
            break
        case ContentType.AUDIO.rawValue:
            message.append("[ audio content ]")
            break
        case ContentType.VIDEO.rawValue:
            message.append("[ video content ]")
            break
        case ContentType.STORY.rawValue:
            message.append("[ story content ]")
            break
        case ContentType.SHARED.rawValue:
            message.append("[ shared story content ]")
            break
            
            
        default:
            return ""
            
        }
        
        return message
    }

    //MARK Content Type
    private func isOwner(id : String) -> Bool {
        return id == userModel.profile!.uuid
    }
    
}

extension ChattingView {
    private func fileBase64Encoding(data : Data,format : String) -> String {
        let base64 = data.base64EncodedString()
        return "data:image/\(format);base64,\(base64)"
    }
    
    private func downloadAndSave(message : RoomMessages)  async{
        hub.SetWait(message: "Downloading and saving...")
        
        let resp = await ChatAppService.shared.DownloadTaskFile(fileURL: message.FileURL)
        hub.isWaiting = false
        switch resp {
        case .success(let fileURL):
            do {
                let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true)
                
                let savedURL = documentsURL.appendingPathComponent(message.file_name!)
                let fileData = try Data(contentsOf: fileURL)
                try fileData.write(to: savedURL)
                self.fileExportURL = savedURL
                self.isFileExport = true
                //                                hub.AlertMessage(sysImg: "checkmark", message: "Saved successfully.")
            }catch (let err){
                //                                print(err.localizedDescription)
                hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            }
            
        case .failure(let err):
            print(err.localizedDescription)
            hub.AlertMessage(sysImg: "exclamationmark.circle", message: err.localizedDescription)
        }
        
    }
    
    private func sendMessage(contentType : String = ContentType.TEXT.rawValue){
        if self.text.isEmpty {
            return
        }
        let msgID = UUID().uuidString
        
        let msg = WSMessage(
            messageID:msgID,
            replyMessageID: nil,
            avatar: self.userModel.profile!.avatar,
            fromUserName: self.userModel.profile!.name,
            fromUUID: self.userModel.profile!.uuid,
            toUUID: self.chatUserData.id!.uuidString.lowercased(),
            content: self.text,
            contentType: contentType,
            eventType: EventType.MESSAGE.rawValue,
            messageType: self.chatUserData.message_type,urlPath: nil,
            fileName: nil,
            fileSize: nil,
            contentAvailableTime: nil,
            contentUUID: nil, 
            contentUserName: nil,
            contentUserAvatar: nil,
            contentUserUUID: nil)
        
        playMessageSentSound()
        Websocket.shared.handleMessage(event:.send,msg: msg)
        
        
        Task {
            await Websocket.shared.checkMessage(messageID: msgID)
        }
        self.text.removeAll()
    }
    
    private func onSendSticker(stickerUri : String,StickerUUID : String){
//        print("sent sticker")
        let msgID = UUID().uuidString

        let msg = WSMessage(messageID:msgID,replyMessageID: nil, avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: nil, contentType: ContentType.STICKER.rawValue, eventType: EventType.MESSAGE.rawValue, messageType: self.chatUserData.message_type,urlPath: stickerUri,fileName: nil,fileSize: nil,contentAvailableTime: nil, contentUUID: StickerUUID, contentUserName: nil,contentUserAvatar: nil,
                            contentUserUUID: nil)

        playMessageSentSound()
        Websocket.shared.handleMessage(event:.send,msg: msg)


        Task {
            await Websocket.shared.checkMessage(messageID: msgID)
        }
    }
    
    private func sendReplyMessage(contentType : String = ContentType.REPLY.rawValue){
        if self.text.isEmpty {
            return
        }
        let msgID = UUID().uuidString
        
        let msg = WSMessage(messageID:msgID,replyMessageID: self.replyMessage!.id!.uuidString, avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: contentType, eventType: EventType.MESSAGE.rawValue, messageType: self.chatUserData.message_type,urlPath: nil,fileName: nil,fileSize: nil,contentAvailableTime: nil, contentUUID: nil, contentUserName: nil,contentUserAvatar: nil,
                            contentUserUUID: nil)

        
        playMessageSentSound()
        Websocket.shared.handleMessage(event:.send,msg: msg)
        
        Task {
            await  Websocket.shared.checkMessage(messageID: msgID)
        }
        self.text.removeAll()
        DispatchQueue.main.async {
            withAnimation{
                self.replyMessage = nil
                self.isReplyMessage = false
            }
        }

    }
    
    private func sendImage(data : String, imageType : String,mediaType : MediaType = .Image) async {
        let sent_time = Date.now
        let message = UDM.addRoomMessage(room: UDM.currentRoom!, msgID : UUID().uuidString,sender_uuid: self.userModel.profile!.uuid, receiver_uuid: self.chatUserData.id!.uuidString.lowercased(),sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: mediaType == .Image ? ContentType.IMAGE.rawValue : ContentType.FILE.rawValue, message_type: self.chatUserData.message_type,sent_at: sent_time,tempData:self.selectedData,fileName: "",fileSize: 0,event: .send,messageStatus: .sending)
        
        chatUserData.last_message = "Sent a \(mediaType.rawValue)"
        chatUserData.last_sent_time = sent_time
        UDM.currentRoomMessage.append(message)
        playMessageSentSound()
        let req = UploadImageReq(image_type: imageType, data: data)
        let resp = await ChatAppService.shared.UploadImage(req: req)
        switch resp{
        case .success(let data):
            //Send to the client and save the message?
            message.tempData = nil
            message.url_path = data.path
            if let index = self.UDM.currentRoomMessage.firstIndex(where: {$0.id == message.id}) {
                withAnimation{
                    self.UDM.currentRoomMessage[index] = message
                }
                
            }
            
            
            let msg = WSMessage(
                messageID:message.id!.uuidString,
                replyMessageID: nil,
                avatar: self.userModel.profile!.avatar,
                fromUserName: self.userModel.profile!.name,
                fromUUID: self.userModel.profile!.uuid,
                toUUID: self.chatUserData.id!.uuidString.lowercased(),
                content: self.text,
                contentType: mediaType == .Image ? ContentType.IMAGE.rawValue : ContentType.FILE.rawValue,
                eventType: EventType.MESSAGE.rawValue,
                messageType: self.chatUserData.message_type,
                urlPath: data.path,
                fileName: nil,
                fileSize: nil,
                contentAvailableTime: nil,
                contentUUID: nil,
                contentUserName: nil,
                contentUserAvatar: nil,
                contentUserUUID: nil)
            
            Websocket.shared.onSendNormal(msg: msg)
            Task {
                await  Websocket.shared.checkMessage(messageID: message.id!.uuidString)
            }

        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
    }
    
    private func sendFile(data : Data,fileName : String,fileSize : Int64,ext : String, type : ContentType) async {
        //file or mp3
        let contentType = type.rawValue
        var sentMsg = "Sent a "
        
        if type == .IMAGE {
            sentMsg.append("image")
        }else if type == .FILE{
            sentMsg.append("file")
        } else if type == .AUDIO {
            sentMsg.append("audio")
        } else if type == .VIDEO {
            sentMsg.append("video")
        }else {
            return
        }
        
        let sent_time = Date.now
        let message = UDM.addRoomMessage(room: UDM.currentRoom!,msgID: UUID().uuidString, sender_uuid: self.userModel.profile!.uuid,receiver_uuid: self.chatUserData.id!.uuidString.lowercased() ,sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: contentType,message_type: self.chatUserData.message_type, sent_at: sent_time,tempData:self.selectedData,fileName: fileName,fileSize: fileSize,event: .send,messageStatus: .sending)
        
        chatUserData.last_message = sentMsg
        chatUserData.last_sent_time = sent_time
        UDM.currentRoomMessage.append(message)
        playMessageSentSound()
//        let req = UploadFileReq(file_name: fileName, data: data)
        let req = UploadFileReq(data: data, file_name: fileName)
        let resp = await ChatAppService.shared.UploadFile(req: req, fileExt: ext)
        switch resp{
        case .success(let data):
            message.tempData = nil
            message.url_path = data.path
            if let index = self.UDM.currentRoomMessage.firstIndex(where: {$0.id == message.id}) {
                withAnimation{
                    self.UDM.currentRoomMessage[index] = message
                }
                
            }
            
            
            let msg = WSMessage(
                messageID:message.id!.uuidString,
                replyMessageID: nil,
                avatar: self.userModel.profile!.avatar,
                fromUserName: self.userModel.profile!.name,
                fromUUID: self.userModel.profile!.uuid,
                toUUID: self.chatUserData.id!.uuidString.lowercased(),
                content: self.text,
                contentType: contentType,
                eventType: EventType.MESSAGE.rawValue,
                messageType: self.chatUserData.message_type,
                urlPath: data.path,
                fileName: fileName,
                fileSize: fileSize,
                contentAvailableTime: nil,
                contentUUID: nil,
                contentUserName: nil,
                contentUserAvatar: nil,
                contentUserUUID: nil)
            
            Websocket.shared.onSendNormal(msg: msg)
            
            Task {
                await Websocket.shared.checkMessage(messageID: message.id!.uuidString)
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
    }
}

extension ChattingView {
    
    @ViewBuilder
    private func TextContentTypeView(message : RoomMessages) -> some View {
        Text(message.content ?? "")
            .font(.system(size:15))
            .padding(10)
            .foregroundColor(Color.white)
            .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color.blue : Color.green)
    }
    
    @ViewBuilder
    private func replyMessageContentTypeView(message : RoomMessages) -> some View {
        
        VStack(alignment:.leading){
            VStack(alignment:.leading){
                Button(action:{
                    print("Find The message???")
                }){
                    VStack(alignment:.leading,spacing:8){
                        Text("\(message.replyMessage?.sender?.name ?? "") \(message.replyMessage?.sent_at?.sendTimeString() ?? "")")
                        Text(message.replyMessageContent)
                            .lineLimit(2)
                    }
                    .font(.system(size:13))
                    .padding(.vertical,10)
                    .padding(.horizontal,10)
                    .foregroundColor(.white)
                    .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color("ReplySenderBlue").cornerRadius(10) : Color("ReplyReceiverGreen").cornerRadius(10))
                    
                }
                .buttonStyle(.plain)

                Text(message.content ?? "")
                    .font(.system(size:15))
                    .foregroundColor(Color.white)
                    
            }
            .padding(10)

               
        }
        .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color.blue : Color.green)

    }

    @ViewBuilder
    private func ImageContentTypeView(message : RoomMessages) -> some View {
        ZStack{
            if message.tempData != nil {
                Image(uiImage: UIImage(data: message.tempData!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay{
                        ZStack{
                            Color.black.opacity(0.75)
                            HStack{
                                Text("Uploading...")
                                    .foregroundColor(.white)
                            }

                        }
                    }
            }else {
                AsyncImage(url: message.FileURL, content: {img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onTapGesture{
                            self.showImageURL = message.FileURL.absoluteString
                            withAnimation{
                                self.isShowImage = true
                            }
                        }
                }, placeholder: {
                    ProgressView()
                        .frame(width: 40,height: 40)

                })
            }
        }
        .transition(.slide)
    }
    
    @ViewBuilder
    private func FileContentTypeView(message : RoomMessages) -> some View {
        ZStack{
            HStack(alignment:.top,spacing:12){
                HStack{
                    Image(systemName: "doc")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
                .padding()
                .cornerRadius(10)
                .overlay{
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(uiColor: UIColor.systemGray6), lineWidth: 1)
                }
                
                
                
                VStack(alignment: .leading,spacing: 5){
                    Text(message.file_name ?? "" )
                        .bold()
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Text("size : \(String(format: "%.2f", message.FileSizeInMB)) MB")
                        .font(.system(size:14))
                    
                }
                
            }
            .padding(10)
            .foregroundColor(Color.white)
            .background(.green)
//            .contextMenu{
//                Button("save to file disk",action:{
//                    Task {
//                        await self.downloadAndSave(message:message)
//                    }
//                })
//                .disabled(message.tempData != nil)
//            }
            .overlay{
                if message.tempData != nil {
                    Color.black
                }
            }

        }
        .transition(.identity)
    }
    
    @ViewBuilder
    private func AudioContentTypeView(message : RoomMessages) -> some View {
        ZStack{
//            if message.tempData != nil {
//                Text("audio sending")
//            }else {
                Button(action: {
                    if message.url_path != nil {
                        withAnimation{
                            self.isPlayAudio = true
                            self.audioInfo = message
                        }
                    }
                   
                }){
                    HStack(alignment:.top,spacing:12){
                        HStack{
                            Image(systemName: "music.note")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .cornerRadius(10)
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: UIColor.systemGray6), lineWidth: 1)
                        }
                        
                        
                        
                        VStack(alignment: .leading,spacing: 5){
                            Text(message.file_name ?? "" )
                                .bold()
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                            
                            Text("size : \(String(format: "%.2f", message.FileSizeInMB)) MB")
                                .font(.system(size:14))
                            
                        }
                        
                    }
                    .padding(10)
                    .foregroundColor(Color.white)
                    .background(.green)
//                    .contextMenu{
//                        Button("save to file disk",action:{
//                            Task {
//                                await self.downloadAndSave(message:message)
//                            }
//                        })
//                        .disabled(message.tempData != nil)
//                    }
                    .overlay{
                        if message.tempData != nil {
                            Color.black
                        }
                        
                    }
                    
//                }


            }
                .disabled(message.tempData != nil)
            
        }
        .transition(.identity)
    }
    
    @ViewBuilder
    private func VideoContentTypeView(message : RoomMessages) -> some View {
        ZStack{
            if message.tempData != nil {
                Rectangle()
                    .fill(Color.black)
                    .cornerRadius(15)
                    .frame(height:200)
                    .overlay{
                        Text("Video Uploading...")
                    }
            }else {
                if let img = getThumbnailImage(forURL: message.FileURL) {
                    Button(action:{
                        withAnimation{
                            //TODO: show player
                            self.isShowVideo = true
                            self.videoURL = message.FileURL
                        }
                    }){
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(15)
                            .overlay{
                                Image(systemName: "play.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                                    .scaleEffect(1.7)
                            }
                    }
//                    .contextMenu{
//                        Button("save to album"){
//                            hub.SetWait(message: "Downloading and saving...")
//                            Task {
//
//                                let resp = await ChatAppService.shared.DownloadTask(fileURL: message.FileURL)
//                                hub.isWaiting = false
//                                switch resp {
//                                case .success(let fileURL):
//                                    do {
//                                        let documentsURL = try
//                                        FileManager.default.url(for: .picturesDirectory,
//                                                                in: .userDomainMask,
//                                                                appropriateFor: nil,
//                                                                create: true)
//
//                                        let savedURL = documentsURL.appendingPathComponent(message.file_name!)
////                                        print(savedURL.absoluteString)
////                                        let fileData = try Data(contentsOf: fileURL)
////                                        try fileData.write(to: savedURL)
//                                        try FileManager.default.moveItem(at: fileURL, to: savedURL)
//                                        PHPhotoLibrary.shared().performChanges({
//                                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savedURL)
//                                        }) { saved, error in
//                                            if saved {
//                                                hub.AlertMessage(sysImg: "checkmark", message: "Saved successfully.")
//                                            }
//                                        }
//
//                                        //                                hub.AlertMessage(sysImg: "checkmark", message: "Saved successfully.")
//                                    }catch (let err){
//                                        //                                print(err.localizedDescription)
//                                        hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
//                                    }
//
//                                case .failure(let err):
//                                    print(err.localizedDescription)
//                                    hub.AlertMessage(sysImg: "exclamationmark.circle", message: err.localizedDescription)
//                                }
//
//                            }
//                        }
//                    }
                    
                }
            }
        }
        .transition(.identity)
    }
    
    @ViewBuilder
    private func StoryContentTypeView(message : RoomMessages) -> some View {
        VStack(alignment:.leading){
            VStack(alignment:.leading){
                Text("Reply to a story")
                    .font(.system(size:14))
                    .fontWeight(.medium)
                    
                    .foregroundColor(Color.white.opacity(0.6) )

                VStack(alignment:.leading,spacing:8){
                    if message.sender!.id!.uuidString.lowercased() != userModel.profile!.uuid {
                        AsyncImage(url: message.FileURL, content: {img in
                            img
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3 / 1.22)
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                                .onTapGesture {
                                    if let id =  message.content_uuid ,!id.isEmpty{
                                        self.toShowStoryId = id
                                        self.friendUUID = self.userModel.profile?.uuid ?? ""
                                        self.isShowStoryViewer = true
                                    }
                                }

                        }, placeholder: {
                            ProgressView()
                                .frame(width: 30,height: 30)

                        })

                    }else {
                        HStack{

                            if message.isStoryAvailable {
                                AsyncImage(url: message.FileURL, content: {img in
                                    img
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3 / 1.22)
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            if let id =  message.content_uuid ,!id.isEmpty &&  chatUserData.id != nil{
                                                    self.toShowStoryId = id
                                                    self.friendUUID = chatUserData.id?.uuidString ?? ""
                                                    self.isShowStoryViewer = true
                                                
                                            }
                                        }

                                }, placeholder: {
                                    ProgressView()
                                        .frame(width: 30,height: 30)

                                })
                            }else {
                                Text("Story unavaiable.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }


                        }

                    }
                }
                .font(.system(size:13))
                .padding(.vertical,10)
                .padding(.horizontal,10)
                .foregroundColor(.white)
                .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color("ReplySenderBlue").cornerRadius(10) : Color("ReplyReceiverGreen").cornerRadius(10))

                Text(message.content ?? "")
                    .font(.system(size:15))
                    .foregroundColor(Color.white)

            }
            .padding(10)
        }
        .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color.blue : Color.green)
    }
    
    @ViewBuilder
    private func StoryShareContentTypeView(message : RoomMessages) -> some View {
        let isSelf = isOwner(id: message.sender!.id!.uuidString.lowercased())
       return VStack(alignment:.leading){
            VStack(alignment: isSelf ?.trailing  : .leading){
                Text("\(isSelf ? "Sent" : "Received") @\(message.content_user_name ?? "--")'s story")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                
                HStack{
                    VStack(alignment:.leading,spacing:8){
                        
                        HStack{
                            if message.isStoryAvailable {
                                AsyncImage(url: message.FileURL, content: {img in
                                        img
                                            .resizable()
                                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3 / 1.22)
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                if let id =  message.content_uuid ,!id.isEmpty && message.content_user_uuid != nil{
                                                    self.toShowStoryId = id
                                                    self.friendUUID = message.content_user_uuid!
                                                    self.isShowStoryViewer = true
                                                }
                                            }
 
                                }, placeholder: {
                                    ProgressView()
                                        .frame(width: 30,height: 30)
                                    
                                })
                                .overlay(alignment:.topLeading){
                                    HStack{
                                        AsyncImage(url: message.StoryUserAvatarURL, content: {img in
                                            img
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width:30,height:35)
                                                .clipShape(Circle())
                                        },placeholder: {
                                            ProgressView()
                                                .frame(width:30,height:35)
                                            
                                        })
                                        
                                        Text("\(message.content_user_name ?? "--")")
                                            .font(.system(size:14))
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                    }
                                    .padding(10)
                                }
                            }else {
                                Text("Story unavaiable.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            
                        }
                    }
                    .font(.system(size:13))
                    .padding(.horizontal,10)
                    .foregroundColor(.white)
                }
                
                
            }
           //            .background(isOwner(id: message.sender!.id!.uuidString.lowercased()) ? Color("ReplySenderBlue").cornerRadius(10) : Color("ReplyReceiverGreen").cornerRadius(10))
           //            .padding(10)
       }

    }
    
    @ViewBuilder
    private func StoryImgContentTypeView(message : RoomMessages) -> some View {
        Text(message.content ?? "")
            .font(.system(size:15))
            .padding(10)
            .foregroundColor(Color.white)
            .background(Color.green)

    }
    
    @ViewBuilder
    private func SysContentTypeView(message : RoomMessages) -> some View {
        Text(message.content ?? "")
            .font(.system(size: 14))
            .padding(.horizontal,8)
            .padding(.vertical,5)
            .cornerRadius(10)
            .background(BlurView(style: .systemMaterialLight).cornerRadius(10))
            .fontWeight(.medium)
    }
    
    @ViewBuilder
    private func StickerContentTypeView(message : RoomMessages) -> some View {
        VStack{
            AsyncImage(url: message.StickerURL, content: {img in
                img
                    .resizable()
                    .scaledToFit()
                    .frame(width:120,height: 120)
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture {
                        if let id = message.content_uuid {
                            withAnimation{
                                self.selectStickerGroupId = id
                                self.isShowStickerInfo = true
                            }
                        }
                    }
            }, placeholder: {
                ProgressView()
                    .scaledToFit()
                    .frame(width:120,height: 120)
                    .aspectRatio(contentMode: .fit)
            })
        }

    }
}

extension ChattingView {
    
    @ViewBuilder
    private func moreContentCell(sysName : String,cellName : String, action : @escaping () -> () ) -> some View {
        Button(action:action){
            VStack(spacing:10){
                Image(systemName: sysName)
                    .imageScale(.large)
                    .foregroundColor(.blue)
                Text(cellName)
                    .foregroundColor(.black)
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .padding(10)
        }

    }
}

extension ChattingView {
    private func setUpVoiceCallingInfoForGroup(){
        guard let sessionId = self.chatUserData.id?.uuidString else {
            print("GroupID not exist")
            return
        }
        
        guard let clientId = self.userModel.profile?.uuid else {
            print("clientId(Producer) not exist")
            return
        }
        
        
        self.sfuProducerVM.start(sessionId: sessionId,clientId: clientId, room: self.chatUserData, type: .Voice) //TODO: creating a new peer if it don't init and setting RTC device
        self.sfuProducerVM.voicePrepare() //TODO: To disable video
        self.sfuProducerVM.callState = .Connecting //TODO: Current status is connecting
        withAnimation{
            self.sfuProducerVM.isIncomingCall = true //TODO: show the view
        }
        //Sending the offer
        self.sfuProducerVM.sendOffer(type:.Voice) //TODO: sending offer to receiver
        self.sfuConsumerVM.setUpSessionManager(sessionId,callType: .Voice)
    }
    
    private func setUpVideoCallingForGroup(){
        guard let sessionId = self.chatUserData.id?.uuidString else {
            print("GroupID not exist")
            return
        }
        
        guard let clientId = self.userModel.profile?.uuid else {
            print("clientId(Producer) not exist")
            return
        }
        
        //Sending the offer
        self.videoCallVM.sendOffer(type:.Video) //TODO: sending offer to receiver
        self.sfuProducerVM.start(sessionId: sessionId,clientId: clientId, room: self.chatUserData, type: .Video) //TODO: creating a new peer if it don't init and setting RTC device
        self.sfuProducerVM.videoPrepare() //TODO: To disable video
        self.sfuProducerVM.callState = .Connecting //TODO: Current status is connecting
        withAnimation{
            self.sfuProducerVM.isIncomingCall = true //TODO: show the view
        }
        //Sending the offer
        self.sfuProducerVM.sendOffer(type:.Video) //TODO: sending offer to receiver
        self.sfuConsumerVM.setUpSessionManager(sessionId,callType: .Video)
    }
    
    private func sendCallingMessage(message : String){
        if message.isEmpty {
            return
        }
        let msgID = UUID().uuidString
        
        let msg = WSMessage(
            messageID:msgID,
            replyMessageID: nil,
            avatar: self.userModel.profile!.avatar,
            fromUserName: self.userModel.profile!.name,
            fromUUID: self.userModel.profile!.uuid,
            toUUID: self.chatUserData.id!.uuidString.lowercased(),
            content: message,
            contentType: ContentType.TEXT.rawValue,
            eventType: EventType.MESSAGE.rawValue,
            messageType: self.chatUserData.message_type,urlPath: nil,
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


struct MessageData : Identifiable {
    let id = UUID().uuidString
    let sender : Int
    let sender_avatar : String
    let content : String
    let message_type : Int
    let content_type : Int
    let PicURL : String
    
    
    var PhotoURL : URL {
        return URL(string: PicURL)!
    }
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + sender_avatar)!
    }
}
