//
//  StoryView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct StoryView: View {
    @EnvironmentObject private var storyModel : StoryViewModel
    var body: some View {
        if self.storyModel.isShowStory {
            TabView(selection: $storyModel.currentStory){
                ForEach($storyModel.stories){ story in
                    StoryCardView(storyBuddle: story)
                        .environmentObject(storyModel)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color.black)
            .transition(.move(edge: .bottom))

        }
    }
}

//struct StoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryView()
//    }
//}
