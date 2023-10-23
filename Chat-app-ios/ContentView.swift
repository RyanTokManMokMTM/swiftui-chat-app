//
//  ContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.

import SwiftUI
import AVFoundation



struct ContentView: View {
    @StateObject var state = SearchState()
    @StateObject var stickerShopVM = StickerShopViewModel()
    @StateObject var UDM : UserDataModel = UserDataModel.shared //Core data model
    @StateObject var storyModel = StoryViewModel()
    @StateObject var hub = BenHubState.shared
    @StateObject var path = NavigationState.shared
    @StateObject var userModel = UserViewModel()
    @StateObject var userStory = UserStoryViewModel()
    @State private var loginSate = true
    @State private var isShowMenu = false
    @State private var menuIndex : Int = 0
    @State private var isShowProfile = false
    @State private var isSearch = false
    @State private var isAddStory : Bool = false
    @Namespace var namespace
    var body: some View {

        ZStack{
            NavigationStack(path:$path.navigationRoomPath){
                HomeView(isShowMenu: $isShowMenu,menuTab: $menuIndex, isAddStory: $isAddStory)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .environmentObject(storyModel)
                    .environmentObject(userStory)
                    .environmentObject(stickerShopVM)

            }
            .accentColor(.green)
            .zIndex(1)
            .fullScreenCover(isPresented: $isShowProfile){
                ProfileView(isShowSetting: $isShowProfile,loginState: $loginSate)
                    .environmentObject(userModel)
            }
            .fullScreenCover(isPresented: $isAddStory){
                StoryPhototView(isAddStory: $isAddStory)
                    .environmentObject(userModel)
                    .environmentObject(userStory)
            }
            .fullScreenCover(isPresented: $storyModel.isShowStory){
                StoryOtherView()
                    .environmentObject(storyModel)
                    .environmentObject(userModel)
                    .onDisappear{
                        self.storyModel.currentStory = 0
                    }
            }
            .fullScreenCover(isPresented: $userStory.isShowStory){
                StoryUserView()
                    .environmentObject(userModel)
                    .environmentObject(userStory)
            }
            .fullScreenCover(isPresented: $isAddStory){
                StoryPhototView(isAddStory: $isAddStory)
                    .environmentObject(userModel)
                    .environmentObject(userStory)
            }


            if isShowMenu {
                NavigationStack(){
                    SideMenu(isShow: $isShowMenu, isShowProfile: $isShowProfile,isAddStory: $isAddStory,menuIndex: $menuIndex,isSearching: $isSearch){
                        ScrollView(.vertical,showsIndicators: false){
                            menuRow(tagIndex:0,sysImg: "message.fill", rowName: "Chats", selected: $menuIndex, namespace: namespace){
                                withAnimation{
                                    self.menuIndex = 0
                                }
                            }

                            NavigationLink(destination: SearchView().environmentObject(state),isActive: $isSearch){
                                menuRow(tagIndex:1,sysImg: "magnifyingglass", rowName: "Find Friends", selected: $menuIndex,namespace: namespace){
                                    withAnimation{
                                        self.menuIndex = 1
                                        self.isSearch = true
                                    }
                                }


                            }
                            .onReceive(self.state.$isChatFromProfile) { toRoot in
                                if toRoot  {
                                    self.state.isChatFromProfile = false
                                    var room : ActiveRooms

                                    guard let profile = self.state.chatUser else {
                                        return
                                    }

                                    if let userRoom = UserDataModel.shared.findOneRoom(uuid: profile.UserUUID){
                                        room = userRoom
                                    }else {
                                        if let newRoom = UserDataModel.shared.addRoom(id: profile.uuid, name: profile.name, avatar: profile.avatar, message_type: 1) {
                                            room = newRoom
                                        }else {
                                            print("failed to create a new room")
                                            return
                                        }

                                    }
                                    self.isSearch = false
                                    self.isShowMenu = false
                                    self.menuIndex = 0
                                    NavigationState.shared.navigationRoomPath.append(room)

                                }

                            }
                            .buttonStyle(.plain)


                        }
                    }
                    .environmentObject(userModel)

                    //                    .navigationTitle("")
                }.accentColor(.black)
                    .zIndex(2)

            }

            if self.loginSate {
                SignInView(isLogin: $loginSate)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .environmentObject(storyModel)
                    .environmentObject(userStory)
                    .transition(.move(edge: .bottom))
                    .background(.white)
                    .zIndex(3)


            }
        }
        .onChange(of: loginSate){ state in
            if state == true{
//                print("log out")
                DispatchQueue.main.async {
                    self.isShowMenu = false
                }
            }
        }
        .wait(isLoading: $hub.isWaiting){
            BenHubLoadingView(message: hub.message)
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

    private func resetAll(){
        DispatchQueue.main.async {
            self.hub.reset()
            self.storyModel.reset()
            self.userModel.reset()
            self.userStory.reset()
            self.state.reset()
            self.UDM.reset()
            Websocket.shared.reset()
        }
    }
}
