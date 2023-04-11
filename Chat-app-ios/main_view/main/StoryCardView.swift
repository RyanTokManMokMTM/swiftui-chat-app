//
//  StoryCardView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct StoryCardView: View {
    @Binding var storyBuddle : StoryBuddle
    @EnvironmentObject private var storyModel : StoryViewModel
    @State private var comment : String = ""
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeProgress : CGFloat = 0
    @State private var index = 0
    var body: some View {
        GeometryReader{ reader in
            ZStack{
                Image(storyBuddle.stories[getStoryIndex()].imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            .overlay{
                HStack(spacing:0){
                    //TODO: Tap on left -> moving backward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move backward
                            print("back")
                            if (self.timeProgress - 1) < 0 {
                                //Move back to other story section
                                updateStory(isForward: false)
                            }else {
                                //Move back to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) - 1)
                            }
                        }
                    //TODO: Tap on right -> moving forward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move forward
                            print("front")
                            if (self.timeProgress + 1) > CGFloat(self.storyBuddle.stories.count) {
                                //Move to other story section
                                updateStory(isForward: true)
                            }else {
                                //Move to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) + 1)
                            }
                        }
                }
            }
            .overlay(alignment:.topTrailing,content: {
                VStack{
                    HStack{
                        HStack{
                            AsyncImage(url: storyBuddle.profileAvatarURL, content: { img in
                                img
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:35,height:35)
                                    .clipShape(Circle())
                                
                            }, placeholder: {
                                ProgressView()
                                    .frame(width:35,height:35)
                                   
                            })
                            
                            VStack(alignment:.leading){
                                Text(storyBuddle.profileName)
                                    .font(.system(size:15))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(storyBuddle.stories[getStoryIndex()].createTime.hourBetween())
                                    .font(.system(size:13))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                        Button(action:{
                            withAnimation{
                                self.storyModel.isShowStory = false
                            }
                        }){
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.black.cornerRadius(25))
                        }
                    }
                    Spacer()
                    HStack{
                        HStack{
                            TextField(text: $comment) {
                                Text("Comment").foregroundColor(.white)
                            }
                                .padding(8)
                                .padding(.horizontal,5)
                        }
                        .background(Color.clear.clipShape(CustomConer(coners: .allCorners)).overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.white, lineWidth: 1)
                        ))
                        
                        HStack{
                            
                            Button(action:{
                                
                            }){
                                Image(systemName: "heart")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                
                            Button(action:{
                                
                            }){
                                Image(systemName: "paperplane")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal,5)
                            
                    }
                  
                    
               
                }
                .padding()
            }) //the close button
            .overlay(alignment:.top,content: {
                HStack(spacing:3){
                    //MARK: Story Time line
                    ForEach(storyBuddle.stories.indices){ index in
                        GeometryReader{ reader in
                            let width = reader.size.width
                            
                            let progress = timeProgress - CGFloat(index)
                            let percent = min(max(progress,0),1) //progress between 0 and 1
                            Capsule()
                                .fill(.gray.opacity(0.5))
                                .overlay(alignment:.leading,content: {
                                    Capsule()
                                        .fill(.white)
                                        .frame(width:width * percent)
                                })
                        }
                        
                        
                    }
                }
                .frame(height: 2)
                .padding(.horizontal)
            })
            .rotation3DEffect(getAngle(proxy: reader), axis: (x:0,y:1,z:0),anchor: reader.frame(in: .global).minX > 0 ? .leading : .trailing,perspective: 2.5)
            .onReceive(self.timer){ t in
                if storyModel.currentStory == storyBuddle.id {
                    //TODO: Update story state
                    if !storyBuddle.isSeen {
                        storyBuddle.isSeen = true
                    }
                    
                    if self.timeProgress < CGFloat(storyBuddle.stories.count){
                        //TODO: for current section
                        self.timeProgress += 0.03
                    } else {
                        updateStory(isForward: true)
                    }
                }
            }
            .onAppear{
                //TODO: Reset time progress
                self.timeProgress = 0
            }
        }
    }
    
    private func getStoryIndex() -> Int {
        return min(Int(self.timeProgress),self.storyBuddle.stories.count - 1)
    }
    private func getAngle(proxy : GeometryProxy) -> Angle{
        let progress = proxy.frame(in: .global).minX / proxy.size.width
//        print(progress)
        let degree = CGFloat(45) * progress
//        print("degree : \(degree)")
        return Angle(degrees: Double(degree))
    }
    
    private func updateStory(isForward : Bool) {
        let index = min(Int(self.timeProgress),self.storyBuddle.stories.count - 1)
        let story = self.storyBuddle.stories[index]
        
        if !isForward {
            //MARK: Move backward
            if let lastStory = self.storyModel.stories.last,lastStory.id == storyBuddle.id {
                let currentSectionIndex = self.storyModel.stories.firstIndex(where: {$0.id == storyBuddle.id}) ?? 0
                
                withAnimation{
                    self.storyModel.currentStory = self.storyModel.stories[currentSectionIndex - 1].id
                }
            }else {
                self.timeProgress = 0
            }
            return
        }
        
        
        //TODO: Check if the story is the last one(Forward)
        if let last = self.storyBuddle.stories.last,last.id == story.id {
            //TODO: if there is any other story section,move to the other stroy section else close the story view
            if let lastStory = self.storyModel.stories.last,lastStory.id == storyBuddle.id{
                withAnimation{
                    self.storyModel.isShowStory = false
                }
                self.timeProgress = 0
            }else {
                let currentSectionIndex = self.storyModel.stories.firstIndex(where: {$0.id == storyBuddle.id}) ?? 0
                
                withAnimation{
                    self.storyModel.currentStory = self.storyModel.stories[currentSectionIndex + 1].id
                }
            }
        }
    }
}
