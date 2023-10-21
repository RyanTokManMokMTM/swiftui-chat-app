//
//  UserStoryCardView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/7/2023.
//

import Foundation
import SwiftUI

struct UserStoryCardView: View {
    @StateObject private var hub = BenHubState.shared
    
    @State private var storyInfo : StoryInfo?
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeProgress : CGFloat = 0
    @State private var likeCount = 0
    @State private var isShowSeenList = false
    @State private var isAction : Bool = false
    
    @State private var isSeenMessage : Bool = false
    @State private var messageTarget : StorySeenInfo? = nil
    @State private var  isAlert : Bool = false
    var body: some View {
        GeometryReader{ reader in
            ZStack{
                AsyncImage(url: self.storyInfo?.MediaURL, content: { img in
                    VStack{
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .top)
                            .cornerRadius(10)
                            .clipped()
                    }
                }, placeholder: {
                    ProgressView()
                })
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
            .overlay{
                HStack(spacing:0){
                    //TODO: Tap on left -> moving backward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move backward
//                            print("back")
                            if (self.timeProgress - 1) < 0 {
                                withAnimation{
                                    self.userStory.isShowStory = false
                                }
                            }else {
                                //Move back to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) - 1)
                                self.userStory.currentStoryIndex = self.userStory.currentStoryIndex - 1
                                self.userStory.currentStoryID = self.userStory.userStories[self.userStory.currentStoryIndex]
                            }
                        }
                    //TODO: Tap on right -> moving forward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move forward
//                            print("front")
                            if (self.timeProgress + 1) > CGFloat(self.userStory.userStories.count) {
                                //Move to other story section
                                withAnimation{
                                    self.userStory.isShowStory = false
                                }
                            }else {
                                //Move to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) + 1)
                                self.userStory.currentStoryIndex = self.userStory.currentStoryIndex + 1
                                self.userStory.currentStoryID = self.userStory.userStories[self.userStory.currentStoryIndex]
                            }
                        }
                }
            }
            .overlay(alignment:.topTrailing,content: {
        
                HStack{
                    HStack{
                        AsyncImage(url: userModel.profile!.AvatarURL, content: { img in
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
                            Text(userModel.profile!.name)
                                .font(.system(size:15))
                                .bold()
                                .foregroundColor(.white)
                            
                            Text(storyInfo?.CreatedTime.hourBetween() ?? "--")
                                .font(.system(size:13))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    Button(action:{
                        withAnimation{
                            self.userStory.isShowStory = false
                        }
                    }){
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.black.cornerRadius(25))
                    }
                }
                .padding()
            }) //the close button
            .overlay(alignment:.top,content: {
                HStack(spacing:3){
                    //MARK: Story Time line0p;
                    ForEach(userStory.userStories.indices,id: \.self){ index in
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
                .frame(height: 3)
                .padding(.horizontal)
            })
            .overlay(alignment:.bottom){
                
                HStack(alignment:.bottom){
                    ZStack{
                        Button(action:{
                            //TODO: DO Nothing right now
                            withAnimation{
                                self.isShowSeenList = true
                            }
                        }){
                            VStack {
                                if let seenList = self.storyInfo?.story_seen_list {
                                    seenUserListView(seenList: seenList)
                                    Text("Views")
                                        .foregroundColor(.white)
                                        .font(.system(size:12))
                                        .fontWeight(.medium)
                                       
                                    
                                }
                            }
                        }
                        .frame(maxWidth: 70)
                        
                        ForEach(0..<self.likeCount,id:\.self){ _ in
                            Image(systemName: "heart.fill")
                                .imageScale(.large)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .modifier(LoveTapModifier())
                        }
                    }
                    
                    Spacer()
                    
                    HStack{
                        Button(action:{
                            self.isAlert = true
                        }){
                            Image(systemName: "trash")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                                .padding(8)

                        }
                        
                    }
                    .padding(.horizontal,5)

                }
                .padding(.horizontal,5)
            }
            .overlay{
                if isShowSeenList {
                    Color.black.opacity(0.65).edgesIgnoringSafeArea(.all)
                }
            }
            .rotation3DEffect(getAngle(proxy: reader), axis: (x:0,y:1,z:0),anchor: reader.frame(in: .global).minX > 0 ? .leading : .trailing,perspective: 2.5)
            .onReceive(self.timer){ t in
                if self.isAction || self.isShowSeenList || self.isAlert {
                    return
                }
                //TODO: Update story state
                if !userStory.isSeen {
                    userStory.isSeen = true
                }
                
                if self.timeProgress < CGFloat(userStory.userStories.count){
                    //TODO: for current section
                    self.timeProgress += 0.01
                    self.userStory.currentStoryIndex = min(Int(self.timeProgress), self.userStory.userStories.count - 1 )
                    self.userStory.currentStoryID = self.userStory.userStories[self.userStory.currentStoryIndex]
                } else {
                    userStory.isShowStory = false
                }
                
 
            }
            .onAppear{
                //TODO: Reset time progress
                self.timeProgress = 0
            }
            .onChange(of: self.userStory.currentStoryID){ id in
                Task{
                    await getStoryInfo(storyID: id)
                }
            }
        }
        .alert(isPresented:$isAlert) {
            Alert(
                title: Text("Delete this story?"),
                message: Text("This will be permanently delete."),
                primaryButton: .destructive(Text("Delete")) {
                    self.isAction = true
                    hub.SetWait(message: "Deleting...")
                    Task{
                        if await self.userStory.deleteStory(storyID:self.userStory.currentStoryID){
                            hub.isWaiting = false
                            hub.AlertMessage(sysImg: "checkmark", message: "Removed.")
                            self.timeProgress = CGFloat(self.userStory.currentStoryIndex)
                            self.isAction = false
                            
                            
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isShowSeenList){
            ZStack {
                
                StorySeenListView(isShowSeenList:$isShowSeenList,isSendMessage: $isSeenMessage,messageTarget : $messageTarget, timeProgress: self.$timeProgress)
                    .environmentObject(userStory)
                    .environmentObject(userModel)
                    .onAppear{
                        Task {
                            await self.userStory.GetStorySeenList(storyID: self.userStory.currentStoryID)
                        }
                    }
                    .padding(.top)
                    .presentationDetents([.large])
                    .zIndex(0)
                
                ZStack(alignment: .bottom){
                    if self.isSeenMessage {
                        Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                            .onTapGesture{
                                withAnimation{
                                    self.isSeenMessage = false
                                }
                            }
                        if let target = self.messageTarget {
                            StoryMessageView(info:target, isAction: $isSeenMessage)
                                .transition(.move(edge: .bottom))
                        }
                    }
                        
                }
                 
             
                    
            }
            .animation(.default, value: isSeenMessage)

   
             
        }
        .onAppear{
            self.userStory.currentStoryIndex = 0
            self.userStory.currentStoryID = self.userStory.userStories.first!
            Task {
                await getStoryInfo(storyID: self.userStory.currentStoryID)
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
    
    private func getStoryInfo(storyID : UInt) async {
        self.likeCount = 0
        let resp = await ChatAppService.shared.GetStoryInfo(storyID: storyID)
        switch resp {
        case .success(let data):
            self.storyInfo = StoryInfo(id: data.story_id, media_url: data.media_url, create_at: data.create_at, is_liked: data.is_liked,story_seen_list: data.story_seen_list)
            if data.is_liked{
                self.likeCount = 10
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getStoryIndex() -> Int {
        return min(Int(self.timeProgress),self.userStory.userStories.count - 1)
    }
    
    private func getAngle(proxy : GeometryProxy) -> Angle{
        let progress = proxy.frame(in: .global).minX / proxy.size.width
//        print(progress)
        let degree = CGFloat(45) * progress
//        print("degree : \(degree)")
        return Angle(degrees: Double(degree))
    }
    
    @ViewBuilder
    private func seenUserView(info : StorySeenUserBasicInfo) -> some View {
        HStack{
            AsyncImage(url: info.AvatarURL, content: { img in
                VStack{
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:25,height:25)
                        .clipShape(Circle())
                }
            }, placeholder: {
                ProgressView()
                    .frame(width: 25,height: 25)
            })
        }
        .frame(width:30,height:30)
        .background(Color.black)
        .clipShape(Circle())
    }
    
    
    @ViewBuilder
    private func seenUserListView(seenList : [StorySeenUserBasicInfo]) -> some View {
        var offestSize = 0
        if seenList.count == 2{
            offestSize = 30 - 18
        } else if seenList.count == 3{
            offestSize =  (30 - 18) * 2
        }
        let frameWidth = 30 * seenList.count - offestSize
        return HStack{
            ZStack{
                ForEach(0..<seenList.count,id:\.self){ index in
                    seenUserView(info: seenList[index])
                        .offset(x : CGFloat(index * 18) ,y : CGFloat(seenList.count >= 3 && index == 1 ? -10 : 0 ))
                        .zIndex(Double(seenList.count >= 3 && index == 1 ? 10 : index + 1))
                }
            }
        }
       .frame(width: CGFloat(frameWidth),alignment: .leading)
        .padding(0)
    }
    

}
