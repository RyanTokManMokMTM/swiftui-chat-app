//
//  HomeView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI

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
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @Environment(\.colorScheme) var colorScheme
    
    

    @State private var index = 0
    @State private var search = ""
    @State private var isShowSheet = false
    @State private var isActive = true
    @Binding var isShowMenu : Bool
    @Binding var menuTab : Int
    
    
    @State private var isShowProfile : Bool = false
    var body: some View {
        ZStack{
 
            TabView(selection:$index){
                Message(isActive: $isActive)
                    .environmentObject(userModel)
                    .environmentObject(UDM)
                    .tabItem{
                        VStack{
                            Image(systemName: "message.fill")
                            Text("Messages")
                        }
                    }
                    .tag(0)
                    .badge(99)
                
                
                CallView()
                    .tabItem{
                        VStack{
                            Image(systemName: "phone.fill")
                            Text("Calls")
                        }
                        
                    }
                    .tag(1)
                    .environmentObject(userModel)
                
                //            NavigationStack{
                FriendContent()
                    .tabItem{
                        VStack{
                            Image(systemName: "person.2")
                            Text("Friends")
                        }
                        
                    }
                    .tag(2)
                    .badge(5)
                    .environmentObject(userModel)
                
                
                
            }
            .navigationTitle("99+")
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
                            self.isShowSheet.toggle()
                        }
                    }){
                        Image(systemName: tags[self.index].toolbarIcon)
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    
                    
                }
                
            }
            .searchable(text: $search,placement: .navigationBarDrawer,prompt: "search")
        }
        .sheet(isPresented: $isShowSheet){
            AddContent(isAddContent: $isShowSheet)
                .environmentObject(UDM)
        }

      
//        .accentColor(.green)
        
    }
    

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(isShowMenu: .constant(false), menuTab: .constant(0))
    }
}
