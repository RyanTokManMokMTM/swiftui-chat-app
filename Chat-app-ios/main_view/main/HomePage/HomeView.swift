//
//  HomeView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI
import PhotosUI

struct MenuTag : Identifiable {
    let id : Int
    let navBarTitle : String
    let toolbarIcon : String
}

let tags : [MenuTag] = [
    MenuTag(id: 0, navBarTitle: "Messages",toolbarIcon: "plus.circle"),
    MenuTag(id: 1, navBarTitle: "Calls",toolbarIcon: "video.fill"),
    MenuTag(id: 2,navBarTitle: "Friends",toolbarIcon: ""),
]


struct HomeView: View {
    
    @EnvironmentObject private var storyModel : StoryViewModel
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var videoCallVM = RTCViewModel()
    @StateObject private var producerVM = SFProducerViewModel()
    @StateObject private var consumerVM = SFUConsumersManager()
    @StateObject var hub = BenHubState.shared
    @State private var index = 0
    @State private var search = ""
    @State private var isShowSheet = false
    @State private var isActive = true
    @Binding var isShowMenu : Bool
    @Binding var menuTab : Int
    @Binding var isAddStory : Bool
    @State private var selectedItem : PhotosPickerItem? = nil
    
    @State private var isShowProfile : Bool = false
    var body: some View {
        ZStack{
            //            TabView(selection:$index){
            Message(isActive: $isActive,isAddStory:$isAddStory)
                .environmentObject(userModel)
                .environmentObject(UDM)
                .environmentObject(storyModel)
                .environmentObject(userStory)
                .environmentObject(videoCallVM)
                .environmentObject(producerVM)
                .environmentObject(consumerVM)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text(tags[self.index].navBarTitle)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading){
                        Button(action:{
                            withAnimation{
                                self.isShowMenu = true
                            }
                        }){
                            Image(systemName: "list.bullet")
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                        
                    }
                
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(action:{
                            withAnimation{
                                self.isShowSheet = true
                            }
                        }){
                            Image(systemName: tags[self.index].toolbarIcon)
                                .imageScale(.large)
                                .foregroundColor(Color.green)
                                .bold()
                        }
                        
                        
                    }
                    
                }
        }
        .fullScreenCover(isPresented: self.$videoCallVM.isIncomingCall){
            if self.videoCallVM.callingType == .Voice {
                VoiceCallView(name: self.videoCallVM.userName ?? "UNKNOW", path: URL(string:RESOURCES_HOST + (self.videoCallVM.userAvatar ?? "/default.jpg"))!)
//                    .environmentObject(userModel)
                    .environmentObject(videoCallVM)
            }else {
                VideoCallView(name: self.videoCallVM.userName ?? "UNKNOW", path: URL(string:RESOURCES_HOST + (self.videoCallVM.userAvatar ?? "/default.jpg"))!)
//                    .environmentObject(userModel)
                    .environmentObject(videoCallVM)
            }
        }
        .fullScreenCover(isPresented: self.$producerVM.isIncomingCall){
            if self.producerVM.callingType == .Voice {
                GroupCallingAudioView()
                     .environmentObject(producerVM)
                     .environmentObject(consumerVM)
            }else {
                GroupCallingVideoView()
                     .environmentObject(producerVM)
                     .environmentObject(consumerVM)
            }
        }

        .sheet(isPresented: $isShowSheet){
            AddContent(isAddContent: $isShowSheet)
                .environmentObject(UDM)
                .environmentObject(userModel)
        }

    }
    

}
