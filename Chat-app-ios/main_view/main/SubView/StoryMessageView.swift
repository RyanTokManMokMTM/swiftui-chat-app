//
//  StoryMessageView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 2/10/2023.
//

import SwiftUI

struct StoryMessageView: View {
    var info : StorySeenInfo
    
    @Binding var isAction : Bool
    @State private var message : String = ""
    @FocusState private var isFocus : Bool
    
    @EnvironmentObject var userModel : UserViewModel
    @StateObject private var hub = BenHubState.shared
    
    var body: some View {
        VStack(alignment:.leading,spacing: 25){
            HStack(spacing:15){
                AsyncImage(url: info.AvatarURL, transaction: .init(animation: .easeInOut)){ result in
                    switch result {
                    case .success(let img):
                        img
                            .resizable()
                            .frame(width:45,height:45)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                    default:
                        ProgressView()
                            .frame(width:45,height:45)
                    }
                }

                HStack(spacing:10){
                    Text("Message to \(info.name)")
                        .foregroundColor(.black)
                        .font(.system(size:14))
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .scaleEffect(0.8)
                }
                
                
            }
            
            HStack{
                TextField(text: $message) {
                    Text("Send message")
                        .foregroundColor(.gray)
                        .fontWeight(.medium)
                        .font(.system(size: 14))
                }
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(8)
                .padding(.horizontal,5)
                .focused($isFocus)

                if !self.message.isEmpty {
                    Button(action:{
                        Task {
                            await self.sendMessage()
                        }
                    }){
                        Text("Send")
                            .fontWeight(.medium)
                            .font(.system(size: 14))
                    }
                    .padding(.horizontal,5)
                }
                    
               
                
            }
            .padding(.horizontal,10)
            .background(Color.clear.clipShape(CustomConer(coners: .allCorners)).overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            ))
            
        }
        .padding(15)
        .background(Color.white.clipShape(CustomConer(width: 10,height: 10, coners: [.topLeft,.topRight])).edgesIgnoringSafeArea(.all))
    }
    
    private func sendMessage() async{
        if message.isEmpty {
            return
        }
        let sendMsg = WSMessage(
            messageID: UUID().uuidString,
            replyMessageID: nil, avatar: self.userModel.profile!.avatar,
            fromUserName: self.userModel.profile!.name,
            fromUUID: self.userModel.profile!.uuid,
            toUUID: self.info.uuid,
            content: self.message,
            contentType: ContentType.text.rawValue,
            type: 4,
            messageType: 1,
            urlPath: nil,
            fileName: nil,
            fileSize: nil,
            storyAvailableTime: 0,
            storyId: nil,
            storyUserName: nil,
            storyUserAvatar: nil,
            storyUserUUID: nil)
        Websocket.shared.handleMessage(event:.send,msg: sendMsg,isGetRoomUserInfo: true){
            withAnimation{
                isAction = false
            }
        }

        self.message.removeAll()
        
    }
}

