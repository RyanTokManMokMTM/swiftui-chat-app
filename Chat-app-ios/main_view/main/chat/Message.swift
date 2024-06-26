//
//  Message.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI

struct Message: View {
    @EnvironmentObject private var storyModel : StoryViewModel
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @StateObject private var messageModel = MessageViewModel()
    @EnvironmentObject private var UDM : UserDataModel
    @EnvironmentObject private var videoCallVM : RTCViewModel
    @EnvironmentObject private var producerVM : SFProducerViewModel
    @EnvironmentObject private var consumerVM : SFUConsumersManager
    @EnvironmentObject var stickerShopVM : StickerShopViewModel
    @Binding var isActive : Bool
    @Binding var isAddStory : Bool
    @State private var isChat = false
    @State private var isShowStory = false
    
    @State private var toUUID : String = ""
    @State private var isSendMessage = false
    @State private var message : String = ""
//    @State private var showSheet = false
    var body: some View {
        
        List{
            ScrollView(.horizontal,showsIndicators: false){
                HStack(spacing: 12){
                    
                    AddActiveItme()
                    ForEach($storyModel.activeStories, id: \.id) { data in
                        StoryProfileView(story: data)
                            .environmentObject(storyModel)
                            .padding(.vertical,5)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical,5)
                
            }
            .listRowInsets(EdgeInsets())
            
            if UDM.info != nil {
                ForEach($UDM.rooms,id:\.id){ data in
                    NavigationLink(value: data.wrappedValue) {
                        ContentRow(data: data)
                            .swipeActions{
                                Button(role: .destructive) {
                                    if UserDataModel.shared.removeAllRoomMessage(room: data.wrappedValue){
                                        UserDataModel.shared.removeActiveRoom(room: data.wrappedValue)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                    }
                }

            }


        }
        .listStyle(.plain)
        .refreshable {
            Task {
                await self.storyModel.GetActiveStory()
            }
        }
        .navigationDestination(for: ActiveRooms.self){data in
//            if let index = UDM.findOneRoomWithIndex(uuid: data.id!){
                ChattingView(chatUserData: data,messages: $UDM.currentRoomMessage)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .environmentObject(videoCallVM)
                    .environmentObject(producerVM)
                    .environmentObject(consumerVM)
                    .environmentObject(stickerShopVM)
                    .onAppear{
                        DispatchQueue.main.async{
//                            self.UDM.currentRoom = index
                            self.UDM.currentRoom = data
                            self.UDM.getMessageCount(room: self.UDM.currentRoom!)
                            self.UDM.fetchCurrentRoomMessage()
                            
                            data.unread_message = 0
                            self.UDM.manager.save()
                        }
                    }
                    .transition(.move(edge: .trailing))
//            }
           
        }
    }
    
    
    private func connectionState() -> Color {
        var color : Color = .clear
        switch self.videoCallVM.connectionStatus {
        case .connected:
            color = .green
        case .disconnected:
            color = .orange
        case .failed, .closed:
            color = .red
        case .new, .connecting:
            color = .black
        @unknown default:
            color = .black
        }
        
        return color
    }
    
    @ViewBuilder
    private func AddActiveItme() -> some View {
        //TODO: if current user is not post any Story -> add button
        //TODO: else current user posted any -> show user post
        VStack{
            
            AsyncImage(url: self.userModel.profile?.AvatarURL ?? URL(string: ""), content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: userStory.userStories.isEmpty ? 75 : 65,height: userStory.userStories.isEmpty ? 75 : 65)
                    .clipShape(Circle())

                   
            }, placeholder: {
                ProgressView()
                    .frame(width:75,height: 75)
            })
        }

       
        .frame(width: 80,height: 80)
        .clipShape(Circle())
        .overlay(alignment:.bottomTrailing){
            if userStory.userStories.isEmpty {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.blue)
                    .background(
                        Color.white.clipShape(Circle()))
            }else {
                if !userStory.isSeen {
                    Circle()
                        .strokeBorder(LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), startPoint: .bottom, endPoint: .top),lineWidth: 3)
                }else {
                    Circle()
                        .strokeBorder(Color(uiColor: .systemGray4),lineWidth: 1)
                }
            }
        }
        .onTapGesture {
            if userStory.userStories.isEmpty {
                DispatchQueue.main.async {
                    self.isAddStory = true
                }
            }else {
                DispatchQueue.main.async {
                    userStory.isShowStory = true
                }
            }
        }
 
    }
    
    
}


struct StoryProfileView : View {
    @EnvironmentObject private var storyModel : StoryViewModel
    @Binding var story : FriendStory
    var body : some View {
        VStack{
            AsyncImage(url: story.AvatarURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:65,height: 65)
                    .clipShape(Circle())
                
            }, placeholder: {
                ProgressView()
                    .frame(width:65,height: 65)
            })
        }
        .frame(width: 80,height: 80)
        .clipShape(Circle())
        .overlay{
            //            if isActive {
            if !story.is_seen {
                Circle()
                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), startPoint: .bottom, endPoint: .top),lineWidth: 3)
            }else {
                Circle()
                    .strokeBorder(Color(uiColor: .systemGray4),lineWidth: 1)
            }
        }
        .onTapGesture {
            withAnimation{
//                self.story.is_seen = true
                self.storyModel.isShowStory = true
                self.storyModel.currentStory = self.story.id
            }
        }
    }
}

//struct Message_Previews: PreviewProvider {
//    static var previews: some View {
//        Message(isActive: .constant(false))
//    }
//}

struct ContentInfo : Identifiable{
    let id : Int
    let name : String
    let avatar : String
    let lastMessage : String
    let lastSent : Date
    let isOnline : Bool
    
    
    var AvatarURL : URL{
        return URL(string: avatar)!
    }
}

struct ContentStory : Identifiable{
    let id : Int
    let name : String
    let avatar : String
    let isRead : Bool
    
    
    var AvatarURL : URL{
        return URL(string: avatar)!
    }
}
