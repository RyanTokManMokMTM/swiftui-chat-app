//
//  ContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userModel = UserViewModel()
    @State private var loginSate = true
    @State private var isShowMenu = false
    var body: some View {
        
        ZStack{
            NavigationStack{
                HomeView(isShowMenu: $isShowMenu)
            }
            .accentColor(.green)
            .fullScreenCover(isPresented: $loginSate){
                SignInView(isLogin: $loginSate)
                    .environmentObject(userModel)
            }
            
            if isShowMenu {
                SideMenu(isShow: $isShowMenu)
                    .environmentObject(userModel)
            }

        }
        
        
        
      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
