//
//  StoryView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct StoryOtherView: View {
    @EnvironmentObject private var storyModel : StoryViewModel
    @EnvironmentObject private var userModel : UserViewModel
    var body: some View {
        if self.storyModel.isShowStory {
            TabView(selection: $storyModel.currentStory){
                ForEach($storyModel.activeStories,id:\.id){ info in
                    OtherStoryCardView(friendInfo: info)
                        .tag(info.id)
                        .environmentObject(storyModel)
                        .environmentObject(userModel)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color.black)
            .transition(.move(edge: .bottom))
            

        }
    }
}
