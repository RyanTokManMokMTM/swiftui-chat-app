//
//  StoryUserView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/7/2023.
//

import Foundation
import SwiftUI

struct StoryUserView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    var body: some View {
        TabView{
            UserStoryCardView()
                .environmentObject(userModel)
                .environmentObject(userStory)
            
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
        .transition(.move(edge: .bottom))
        
        
    }
}
