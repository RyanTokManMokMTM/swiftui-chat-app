//
//  Message.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI

struct Message: View {
    @EnvironmentObject private var userModel : UserViewModel
    @StateObject private var messageModel = MessageViewModel()
    @EnvironmentObject private var UDM : UserDataModel

    
    @Binding var isActive : Bool
    @State private var isChat = false

    var body: some View {
        
        List{
            ScrollView(.horizontal,showsIndicators: false){
                HStack(spacing: 12){

                    AddActiveItme(url: URL(string: "https://i.ibb.co/MP6cDM1/9c7edaa9edbf5d777ead3820b69373f4.jpg")!)
                    
                    ForEach(dummyActiveStory, id: \.id) { data in
                        UserAvatarItem(avatarURL: data.AvatarURL, isRead: data.isRead)
                            .padding(.vertical,5)

                    }
                }
                .padding(.horizontal)
                .padding(.vertical,5)
            }
            .listRowInsets(EdgeInsets())
            
            if UDM.info != nil {
                ForEach($UDM.rooms){ data in
                    NavigationLink(value: data.wrappedValue) {
                        ContentRow(data: data)
                            .swipeActions{
                                Button(role: .destructive) {
                                    print("Deleting conversation")
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                    }
                }
                
            }
           
 
        }
        .listStyle(.plain)
        .navigationDestination(for: ActiveRooms.self){data in
            ChattingView(chatUserData: data,messages: $UDM.currentRoomMessage)
                .environmentObject(userModel)
                .onAppear{
                    self.UDM.currentRoom = self.UDM.findOneRoomWithIndex(uuid: data.id!)!
                    self.UDM.fetchCurrentRoomMessage()
                }
                .onDisappear{
                    self.UDM.currentRoom = -1
                    self.UDM.currentRoomMessage.removeAll()
                }
        }
        
        
    }
    

    @ViewBuilder
    private func AddActiveItme(url : URL) -> some View {
        VStack{
            AsyncImage(url: url, content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:75,height: 75)
                
                    .clipShape(Circle())
                   
                    
                   
            }, placeholder: {
                ProgressView()
                    .frame(width:75,height: 75)
            })
        }
        .frame(width: 80,height: 80)
        .clipShape(Circle())
        .overlay(alignment:.bottomTrailing){
            Image(systemName: "plus.circle.fill")
                .imageScale(.large)
                .foregroundColor(.blue)
                .background(
                    Color.white.clipShape(Circle()))
        }
        
    }

}

struct Message_Previews: PreviewProvider {
    static var previews: some View {
        Message(isActive: .constant(false))
    }
}

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
