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

enum MediaType : String {
    case Image = "image"
    case Video = "video"
}

struct ChattingView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
//    @EnvironmentObject private var messageModel : MessageViewModel
    let chatUserData : ActiveRooms
    @Binding var messages : [RoomMessages]
//    @Binding var isActive : Bool
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
    var body: some View {
        VStack{
            ScrollViewReader { scroll in
                ScrollView(.vertical){
                    VStack{
                        ForEach(messages.indices,id :\.self) { index in
                            VStack(spacing:0){


                                if messages[index].content_type == ContentType.sys.rawValue{
                                    SysContentTypeView(message: messages[index])
                                }else {
                                    ChatBubble(direction: messages[index].sender!.id!.uuidString.lowercased() != userModel.profile!.uuid ? .receiver : .sender,messageType: Int(chatUserData.message_type), userName: messages[index].sender!.name!, userAvatarURL: messages[index].sender!.AvatarURL, contentType: Int(messages[index].content_type)){

                                        if messages[index].content_type == ContentType.text.rawValue {
                                            TextContentTypeView(message: messages[index])
                                        }else if messages[index].content_type == ContentType.img.rawValue{
                                            ImageContentTypeView(message: messages[index])
                                        }else if messages[index].content_type == ContentType.file.rawValue{
                                            FileContentTypeView(message: messages[index])
                                        }
                                        else if messages[index].content_type == ContentType.audio.rawValue {
                                            AudioContentTypeView(message: messages[index])
                                        } else if messages[index].content_type == ContentType.video.rawValue {
                                            VideoContentTypeView(message: messages[index])
                                        }
                                        else if messages[index].content_type == ContentType.story.rawValue {
                                            StoryContentTypeView(message: messages[index])
                                        }
                                    }

                                    //MARK: For show the post info
                                    if  messages[index].content_type == ContentType.story.rawValue {
                                        ChatBubble(direction: messages[index].sender!.id!.uuidString.lowercased() != userModel.profile!.uuid ? .receiver : .sender,messageType: Int(chatUserData.message_type), userName: messages[index].sender!.name!, userAvatarURL: messages[index].sender!.AvatarURL, contentType: 1,isSame:true){
                                            StoryImgContentTypeView(message: messages[index])
                                        }
                                    }

                                }


                            }.id(index)

                        }
                        .onAppear(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                //                                print(messages.count)
                                withAnimation{
                                    scroll.scrollTo(messages.count - 1)
                                }

                            }

                        }

                        .onChange(of: messages.count){ _ in
                            //                            print(index)
                            withAnimation{
                                scroll.scrollTo(messages.count - 1)
                            }

                        }
                    }
                }
            }
 
            
            InputField()
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
                    NavigationLink(destination: OtherGroupProfileView(uuid: self.chatUserData.id!.uuidString, isShowDetail: $isShowInfo)){
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
            
            //TODO: NOT TO IMPLEMENT THIS NOW
//            ToolbarItem(placement: .navigationBarTrailing){
//                HStack{
//                    Button(action:{
//                        withAnimation{
//
//                        }
//                    }){
//                        Image(systemName: "phone.fill")
//                            .imageScale(.large)
//                            .foregroundColor(Color.green)
//                            .bold()
//                    }
//                    Button(action:{
//                        withAnimation{
//
//                        }
//                    }){
//                        Image(systemName: "video.fill")
//                            .imageScale(.large)
//                            .foregroundColor(Color.green)
//                            .bold()
//                    }
//                }
//
//            }
        }
        .onChange(of: self.selectedItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.selectedData = data
                    
                   
                    let fileFormat = data.fileExtension
//                    let base64Str = fileBase64Encoding(data: data,format: fileFormat)
                    let fileName = UUID().uuidString + "." + fileFormat
                    //                    print(fileFormat)
                    Task.init{
                        await self.sendFile(data:data,fileName:fileName,fileSize: 0,ext:fileFormat,type:isVideo(ext:fileFormat) ? .video : .img)
                    }
                }
            }
        }
        .fileExporter(isPresented: $isFileExport, document: Doc(url: self.fileExportURL), contentType: .data) { result in
            switch result {
            case .success(let url):
                print(url)
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
                    print(data.absoluteString)

                    let ext = data.pathExtension
                    Task.init{
                        await self.sendFile(data: fileData, fileName: fileName, fileSize: Int64(fileSize), ext: ext, type: isAudio(ext : ext) ? .audio : .file)
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
    
    private func isAudio(ext : String) -> Bool {
        return ext == "mp3" || ext == "wav" || ext == "m3u" || ext == "m4a"
    }
    
    private func isVideo(ext : String) -> Bool {
        return ext == "mp4"
    }
    
    @ViewBuilder
    func InputField() -> some View{
        VStack{
            HStack{
                Button(action:{
                    withAnimation{
                        self.showPicker.toggle()
                    }
                }){
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .foregroundColor( .blue)
                }
                
                PhotosPicker(selection: $selectedItem, matching: .any(of: [.images,.videos]),photoLibrary: .shared()){
                    Image(systemName: "photo.fill")
                        .imageScale(.large)
                        .foregroundColor( .blue)
                }
                
                TextField("訊息",text:$text)
                    .padding(.horizontal)
                    .frame(height:37)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .focused($isFocus)
                    .submitLabel(.send)
                    .onSubmit{
                        //                        sendMessage()
                        sendMessage()
                        self.messageIndex = messages.count - 1
                    }
                
                

            }
            .frame(height: 37)
        }
        .padding()
        .background(.thickMaterial)
//        .fullScreenCover(isPresented: $isShowInfo){
//            if chatUserData.message_type == 1 {
//                OtherUserProfileView(uuid: self.chatUserData.id!.uuidString,isShowDetail: $isShowInfo)
//            }else {
//                OtherGroupProfileView(uuid: self.chatUserData.id!.uuidString,isShowDetail: $isShowInfo)
//            }
//        }
    }
    
    private func fileBase64Encoding(data : Data,format : String) -> String {
        let base64 = data.base64EncodedString()
        return "data:image/\(format);base64,\(base64)"
    }
    
    private func downloadAndSave(message : RoomMessages)  async{
        hub.SetWait(message: "Downloading and saving...")
        
        let resp = await ChatAppService.shared.DownloadTask(fileURL: message.FileURL)
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
                print(savedURL.absoluteString)
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
    
    private func sendMessage(contentType : Int16 = 1){
        //TODO:
        /*
         messageType : 1 - PM
         From -> current sender user
         To -> ChatRoomUser
         messageType : 2 - Group
         From -> current sender user
         To -> Room UUID
         
         */
        
        let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: contentType, type: 4, messageType: self.chatUserData.message_type,urlPath: nil,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil,storyAvailableTime: nil)
        Webcoket.shared.onSend(msg: msg)
        Webcoket.shared.handleMessage(event:.send,msg: msg)
        self.text.removeAll()
    }
    
    private func sendImage(data : String, imageType : String,mediaType : MediaType = .Image) async {
        let sent_time = Date.now
        let message = UDM.addRoomMessage(roomIndex: UDM.currentRoom, sender_uuid: self.userModel.profile!.uuid, receiver_uuid: self.chatUserData.id!.uuidString.lowercased(),sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: mediaType == .Image ? 2 : 3, message_type: self.chatUserData.message_type,sent_at: sent_time,tempData:self.selectedData,fileName: "",fileSize: 0,event: .send)
        chatUserData.last_message = "Sent a \(mediaType.rawValue)"
        chatUserData.last_sent_time = sent_time
        UDM.currentRoomMessage.append(message)
        
        let req = UploadImageReq(image_type: imageType, data: data)
        let resp = await ChatAppService.shared.UploadImage(req: req)
        switch resp{
        case .success(let data):
            //Send to the client and save the message?
            message.tempData = nil
            message.url_path = data.path
            print(data.path)
            if let index = self.UDM.currentRoomMessage.firstIndex(where: {$0.id == message.id}) {
                withAnimation{
                    self.UDM.currentRoomMessage[index] = message
                }
                
            }
            
            
            let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: mediaType == .Image ? 2 : 3, type: 4, messageType: self.chatUserData.message_type,urlPath: data.path,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil,storyAvailableTime: nil)
            Webcoket.shared.onSend(msg: msg)
        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
    }
    
    private func sendFile(data : Data,fileName : String,fileSize : Int64,ext : String, type : ContentType) async {
        //file or mp3
        let contentType = type.rawValue
        var sentMsg = "Sent a "
        
        if type == .img {
            sentMsg.append("image")
        }else if type == .file{
            sentMsg.append("file")
        } else if type == .audio {
            sentMsg.append("audio")
        } else if type == .video {
            sentMsg.append("video")
        }else {
            return
        }
        
        let sent_time = Date.now
        let message = UDM.addRoomMessage(roomIndex: UDM.currentRoom, sender_uuid: self.userModel.profile!.uuid,receiver_uuid: self.chatUserData.id!.uuidString.lowercased() ,sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: Int16(contentType),message_type: self.chatUserData.message_type, sent_at: sent_time,tempData:self.selectedData,fileName: fileName,fileSize: fileSize,event: .send)
        
        chatUserData.last_message = sentMsg
        chatUserData.last_sent_time = sent_time
        UDM.currentRoomMessage.append(message)
        
//        let req = UploadFileReq(file_name: fileName, data: data)
        let req = UploadFileReq(data: data, file_name: fileName)
        let resp = await ChatAppService.shared.UploadFile(req: req, fileExt: ext)
        switch resp{
        case .success(let data):
            print(data)
            message.tempData = nil
            message.url_path = data.path
            print(data)
            if let index = self.UDM.currentRoomMessage.firstIndex(where: {$0.id == message.id}) {
                withAnimation{
                    self.UDM.currentRoomMessage[index] = message
                }
                
            }
            
            
            let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: Int16(contentType), type: 4, messageType: self.chatUserData.message_type,urlPath: data.path,groupName: nil,groupAvatar: nil,fileName: fileName,fileSize: fileSize,storyAvailableTime: nil)
            Webcoket.shared.onSend(msg: msg)
        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
    }
    
    //MARK Content Type
    
    @ViewBuilder
    private func TextContentTypeView(message : RoomMessages) -> some View {
        Text(message.content ?? "")
            .font(.system(size:15))
            .padding(10)
            .foregroundColor(Color.white)
            .background(Color.green)
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
            .contextMenu{
                Button("save to file disk",action:{
                    Task {
                        await self.downloadAndSave(message:message)
                    }
                })
                .disabled(message.tempData != nil)
            }
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
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            
                            Text("size : \(String(format: "%.2f", message.FileSizeInMB)) MB")
                                .font(.system(size:14))
                            
                        }
                        
                    }
                    .padding(10)
                    .foregroundColor(Color.white)
                    .background(.green)
                    .contextMenu{
                        Button("save to file disk",action:{
                            Task {
                                await self.downloadAndSave(message:message)
                            }
                        })
                        .disabled(message.tempData != nil)
                    }
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
                    .contextMenu{
                        Button("save to album"){
                            hub.SetWait(message: "Downloading and saving...")
                            Task {
                                
                                let resp = await ChatAppService.shared.DownloadTask(fileURL: message.FileURL)
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
//                                        print(savedURL.absoluteString)
//                                        let fileData = try Data(contentsOf: fileURL)
//                                        try fileData.write(to: savedURL)
                                        try FileManager.default.moveItem(at: fileURL, to: savedURL)
                                        PHPhotoLibrary.shared().performChanges({
                                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savedURL)
                                        }) { saved, error in
                                            if saved {
                                                hub.AlertMessage(sysImg: "checkmark", message: "Saved successfully.")
                                            }
                                        }
                 
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
                        }
                    }
                    
                }
            }
        }
        .transition(.identity)
    }
    @ViewBuilder
    private func StoryContentTypeView(message : RoomMessages) -> some View {
        VStack(alignment:message.sender!.id!.uuidString.lowercased() != userModel.profile!.uuid  ? .leading : .trailing,spacing:0){


            Text("Reply to a story")
                .font(.footnote)
                .foregroundColor(.gray)


            if message.sender!.id!.uuidString.lowercased() != userModel.profile!.uuid {

                HStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor:UIColor.systemGray2))
                        .frame(width:5,height:100)
                        .padding(.vertical)
                    AsyncImage(url: message.FileURL, content: { img in
                        img
                            .resizable()
                            .frame(maxWidth:60,maxHeight:95)
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(10)

                    }, placeholder: {
                        ProgressView()
                            .frame(width: 30,height: 30)

                    })
                }


            }else {
                HStack{

                    if message.isStoryAvailable {
                        AsyncImage(url: message.FileURL, content: {img in
                            img
                                .resizable()
                                .frame(maxWidth:60,maxHeight:95)
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                                .frame(height:40)
                        }, placeholder: {
                            ProgressView()
                                .frame(width: 30,height: 30)

                        })
                    }else {
                        Text("Story unavaiable.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }


                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor:UIColor.systemGray2))
                        .frame(width:5,height:message.isStoryAvailable ? 100 : 20)
                        .padding(.vertical)
                }

            }

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
}


//struct ChattingView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChattingView(chatUserData: dummyActiveChat[0],messages: dummyChattingMessageRoom1, isActive: .constant(true))
//    }
//}

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
