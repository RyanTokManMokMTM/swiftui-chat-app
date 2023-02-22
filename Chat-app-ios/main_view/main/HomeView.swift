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
    @Environment(\.colorScheme) var colorScheme
    @State private var index = 0
    @State private var search = ""
    @State private var isShowSheet = false
    @State private var isActive = true
    var body: some View {
        NavigationStack{
            TabView(selection:$index){
                //            NavigationStack{
                Message(isActive: $isActive)
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
        .accentColor(.green)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
