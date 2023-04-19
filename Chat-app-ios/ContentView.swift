//
//  ContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import SwiftUI

struct ContentView: View {
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
    var body: some View {
        
        ZStack{
            NavigationStack(path:$path.navigationRoomPath){
                HomeView(isShowMenu: $isShowMenu,menuTab: $menuIndex, isAddStory: $isAddStory)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .environmentObject(storyModel)
                    .environmentObject(userStory)
                
                
            }
            .accentColor(.green)
            .zIndex(1)
            
            
            if isShowMenu {
                NavigationStack(path:$path.navigationRoomPath){
                    SideMenu(isShow: $isShowMenu, isShowProfile: $isShowProfile,isAddStory: $isAddStory){
                        ScrollView(.vertical,showsIndicators: false){
                            menuRow(tagIndex:0,sysImg: "message.fill", rowName: "Chats", selected: $menuIndex){
                                withAnimation{
                                    self.menuIndex = 0
                                }
                            }
                            
                            NavigationLink(destination: SearchView(),isActive: $isSearch){
                                menuRow(tagIndex:1,sysImg: "magnifyingglass", rowName: "Find Friends", selected: $menuIndex){
                                    withAnimation{
                                        self.menuIndex = 1
                                        self.isSearch = true
                                    }
                                }
                                
                            }
                            .buttonStyle(.plain)

                            
                        }
                    }
                    .environmentObject(userModel)
                    .zIndex(2)
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
                    .zIndex(1)
            }
        }
        .wait(isLoading: $hub.isWaiting){
            BenHubLoadingView(message: hub.message)
        }
        .alert(isAlert: $hub.isPresented){
            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
        }
        .sheet(isPresented: $isShowProfile){
            ProfileView(isShowSetting: $isShowProfile)
                .environmentObject(userModel)
        }
        .fullScreenCover(isPresented: $isAddStory){
            StoryPhototView(isAddStory: $isAddStory)
                .environmentObject(userModel)
                .environmentObject(userStory)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
