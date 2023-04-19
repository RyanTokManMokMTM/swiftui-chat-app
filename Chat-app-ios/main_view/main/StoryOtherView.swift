//
//  StoryView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct StoryOtherView: View {
    @EnvironmentObject private var storyModel : StoryViewModel
    var body: some View {
        if self.storyModel.isShowStory {
            TabView(selection: $storyModel.currentStory){
                ForEach($storyModel.activeStories,id:\.id){ info in
                    OtherStoryCardView(friendInfo: info)
                        .tag(info.id)
                        .environmentObject(storyModel)
                        .onAppear{
                            print(info)
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color.black)
            .transition(.move(edge: .bottom))

        }
    }
}

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
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color.black)
        .transition(.move(edge: .bottom))
        
        
    }
}
