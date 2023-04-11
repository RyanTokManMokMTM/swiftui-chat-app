//
//  ChattingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/2/2023.
//

import SwiftUI
import PhotosUI

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
    @State private var text : String = ""
    @FocusState private var isFocus : Bool
    @State private var messageIndex : Int = 0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData : Data? = nil
    
    @State private var showPicker = false
    var body: some View {
        VStack{
            ScrollViewReader { scroll in
                ScrollView(.vertical){
                    VStack{
                        ForEach(messages.indices,id :\.self) { index in
                            ChatBubble(direction: messages[index].sender_uuid!.uuidString.lowercased() != userModel.profile!.uuid ? .receiver : .sender,messageType: Int(chatUserData.message_type), userName: messages[index].sender_name!, userAvatarURL: messages[index].AvatarURL, contentType: Int(messages[index].content_type)){
                                
                                if messages[index].content_type == 1 {
                                    Text(messages[index].content ?? "")
                                        .font(.system(size:15))
                                        .padding(10)
                                        .foregroundColor(Color.white)
                                        .background(Color.green)
                                }else if messages[index].content_type == 2{
                                    ZStack{
                                        if messages[index].tempData != nil {
                                            Image(uiImage: UIImage(data: self.messages[index].tempData!)!)
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
                                            AsyncImage(url: messages[index].FileURL, content: {img in
                                                img
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            }, placeholder: {
                                                ProgressView()
                                                    .frame(width: 40,height: 40)

                                            })
                                        }
                                    }
                                    .transition(.slide)
                                }else if messages[index].content_type == 3{
                                    ZStack{
                                        if messages[index].tempData != nil {
                                            Text("file sending")
                                        }else {
                                            Button(action:{
                                                print(messages[index].url_path)
                                            }){
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
                                                        Text(messages[index].file_name ?? "" )
                                                            .bold()
                                                            .font(.headline)
                                                            .multilineTextAlignment(.leading)
                                                        
                                                        Text("size : \(String(format: "%.2f", messages[index].FileSizeInMB)) MB")
                                                            .font(.system(size:14))
                                                        
                                                    }
                                                        
                                                }
                                                .padding(10)
                                                .foregroundColor(Color.white)
                                                .background(.green)
                                            }
                                            
                                        }
                                    }
                                    .transition(.identity)
                                }
                                
                            }
                            .id(index)
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
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                HStack(){
                    Text(self.chatUserData.name ?? "UNKNOW CHAT")
                        .bold()
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal,5)
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                HStack{
                    Button(action:{
                        withAnimation{
                            
                        }
                    }){
                        Image(systemName: "phone.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    Button(action:{
                        withAnimation{
                            
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
        .onChange(of: self.selectedItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.selectedData = data
                    
                    let fileFormat = data.fileExtension
                    let base64Str = fileBase64Encoding(data: data,format: fileFormat)
//                    print(fileFormat)
                    Task.init{
                        await self.sendImage(data: base64Str, imageType: fileFormat)
                    }
                }
            }
        }
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.data,.pdf,.text,.video,.audio]) { result in
            switch result {
            case .success(let data):
                do {
                    let fileData = try Data(contentsOf: data)
                    let fileSize = data.filesize ?? 0
                    let fileName = data.lastPathComponent
                    Task.init{
                        await self.sendFile(data: fileData.base64EncodedString(), fileName: fileName, fileSize: fileSize)
                    }
//
//
                } catch(let err){
                    print("conver file to data failed \(err.localizedDescription)")
                }
             
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
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
                
                PhotosPicker(selection: $selectedItem, matching: .any(of: [.images]),photoLibrary: .shared()){
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
    }
    
    private func fileBase64Encoding(data : Data,format : String) -> String {
        let base64 = data.base64EncodedString()
        return "data:image/\(format);base64,\(base64)"
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
        
        let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: contentType, type: 4, messageType: self.chatUserData.message_type,urlPath: nil,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil)
        Webcoket.shared.onSend(msg: msg)
        Webcoket.shared.handleMessage(event:.send,msg: msg)
        self.text.removeAll()
    }
    
    private func sendImage(data : String, imageType : String,mediaType : MediaType = .Image) async {
        let sent_time = Date.now
        let message = UDM.addRoomMessage(roomIndex: UDM.currentRoom, sender_uuid: self.userModel.profile!.uuid, sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: mediaType == .Image ? 2 : 3, sent_at: sent_time,tempData:self.selectedData)
        chatUserData.last_message = "[Sent a \(mediaType.rawValue)]"
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
            
            
            let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: mediaType == .Image ? 2 : 3, type: 4, messageType: self.chatUserData.message_type,urlPath: data.path,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil)
            Webcoket.shared.onSend(msg: msg)
        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
    }
    
    private func sendFile(data : String,fileName : String,fileSize : Int) async {
        let sent_time = Date.now
        let message = UDM.addRoomMessage(roomIndex: UDM.currentRoom, sender_uuid: self.userModel.profile!.uuid, sender_avatar: self.userModel.profile!.avatar, sender_name: self.userModel.profile!.name, content: "", content_type: 3, sent_at: sent_time,tempData:self.selectedData,fileName: fileName,fileSize: Int64(fileSize))
        chatUserData.last_message = "[Sent a file]"
        chatUserData.last_sent_time = sent_time
        UDM.currentRoomMessage.append(message)
        
        let req = UploadFileReq(file_name: fileName, data: data)
        let resp = await ChatAppService.shared.UploadFile(req: req)
        switch resp{
        case .success(let data):
            print(data)
            message.tempData = nil
            message.url_path = data.path
            
            if let index = self.UDM.currentRoomMessage.firstIndex(where: {$0.id == message.id}) {
                withAnimation{
                    self.UDM.currentRoomMessage[index] = message
                }
                
            }
            
            
            let msg = WSMessage(avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.chatUserData.id!.uuidString.lowercased(), content: self.text, contentType: 3, type: 4, messageType: self.chatUserData.message_type,urlPath: data.path,groupName: nil,groupAvatar: nil,fileName: fileName,fileSize: Int16(fileSize))
            Webcoket.shared.onSend(msg: msg)
        case .failure(let err):
            print(err.localizedDescription)
        }
        UDM.manager.save()
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
