//
//  StoryCardView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct StoryInfo : Identifiable {
    let id : UInt
    let media_url : String
    let create_at : UInt
    
    var MediaURL : URL {
        return URL(string: RESOURCES_HOST + self.media_url)!
    }
                    
    var CreatedTime : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.create_at))
    }
}

struct OtherStoryCardView: View {
    @Binding var friendInfo : FriendStory
    @State private var story : StoryInfo?
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var storyModel : StoryViewModel
    @State private var comment : String = ""
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeProgress : CGFloat = 0
    @State private var index = 0
    @FocusState private var isFocus : Bool
    var body: some View {
        GeometryReader{ reader in
            ZStack{
                AsyncImage(url: story?.MediaURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea(.keyboard)
                }, placeholder: {
                    ProgressView()
                        
                })
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
            .overlay{
                HStack(spacing:0){
                    //TODO: Tap on left -> moving backward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move backward
                            if (self.timeProgress - 1) < 0 {
                                //Move back to other story section
                                updateStory(isForward: false)
                            }else {
                                //Move back to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) - 1)
                                self.index = Int(self.timeProgress)
                            }
                        }
                    //TODO: Tap on right -> moving forward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
                            //move forward
                            
                            if (self.timeProgress + 1) > CGFloat(friendInfo.stories_ids.count) {
                                //Move to other story section
                                updateStory(isForward: true)
                            }else {
                                //Move to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) + 1)
                                self.index = Int(self.timeProgress)
                            }
                        }
                }
            }
            .overlay(alignment:.topTrailing) {
                VStack{
                    HStack{
                        HStack{
                            AsyncImage(url: friendInfo.AvatarURL, content: { img in
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
                                Text(friendInfo.name)
                                    .font(.system(size:15))
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(story?.CreatedTime.hourBetween() ?? "--")
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
                        VStack{
                            TextField(text: $comment) {
                                Text("Comment")
                                    .foregroundColor(.white)
                            }
                            .foregroundColor(.white)
                                .padding(8)
                                .padding(.horizontal,5)
                                .focused($isFocus)
                                .onSubmit {
                                    Task {
                                        await replyStory()
                                    }
                                }
                                
                        }
                        .background(Color.clear.clipShape(CustomConer(coners: .allCorners)).overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.white, lineWidth: 1)
                        ))
                        
                    }
                  
                    
               
                }
                .padding()
            } //the close button
            .overlay(alignment:.top,content: {
                HStack(spacing:3){
                    //MARK: Story Time line
                    ForEach(self.friendInfo.stories_ids.indices,id:\.self){ index in
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
                if isFocus {
                    return
                }
                if storyModel.currentStory == friendInfo.id {
                    //TODO: Update story state
                    if !friendInfo.is_seen {
                        friendInfo.is_seen = true
                    }
                    
                    if self.timeProgress < CGFloat(friendInfo.stories_ids.count){
                        //TODO: for current section
                        self.timeProgress += 0.01
                        self.index = min(Int(self.timeProgress), friendInfo.stories_ids.count - 1 )
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
        .onChange(of: self.index){ i in
            Task {
                await self.getStoryInfo(storyID: UInt(friendInfo.stories_ids[i]))
            }
        }
        .onAppear{
            Task {
                await self.getStoryInfo(storyID: UInt(friendInfo.stories_ids.first!))
            }
        }
    }
    
    private func replyStory() async{
        if comment.isEmpty {
            return
        }
        
        let sendMsg = WSMessage(messageID: UUID().uuidString,avatar: self.userModel.profile!.avatar, fromUserName: self.userModel.profile!.name, fromUUID: self.userModel.profile!.uuid, toUUID: self.friendInfo.uuid, content: self.comment, contentType: 6, type: 4, messageType: 1, urlPath: self.story!.media_url, fileName: nil, fileSize: nil, storyAvailableTime: Int32(self.story!.create_at), replyMessageID: nil)
      
        Websocket.shared.onSend(msg: sendMsg)
        Websocket.shared.handleMessage(event:.send,msg: sendMsg,isReplyComment: true)
        self.comment.removeAll()
        
    }
    
    private func getStoryInfo(storyID : UInt) async {
        let resp = await ChatAppService.shared.GetStoryInfo(storyID: storyID)
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.story = StoryInfo(id: data.story_id, media_url: data.media_url, create_at: data.create_at)
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getStoryIndex() -> Int {
        return min(Int(self.timeProgress),self.storyModel.activeStories.count - 1)
    }
    private func getAngle(proxy : GeometryProxy) -> Angle{
        let progress = proxy.frame(in: .global).minX / proxy.size.width
//        print(progress)
        let degree = CGFloat(45) * progress
//        print("degree : \(degree)")
        return Angle(degrees: Double(degree))
    }
    
    private func updateStory(isForward : Bool) {
//        let storyIndex = min(Int(self.timeProgress),self.storyModel.activeStories.count - 1)
//        let story = self.storyModel.activeStories[storyIndex]
        
        if !isForward {
            //MARK: Move backward
            if let lastStory = self.storyModel.activeStories.last,lastStory.id == friendInfo.id {
                let currentSectionIndex = self.storyModel.activeStories.firstIndex(where: {$0.id == friendInfo.id}) ?? 0
                if currentSectionIndex == 0 {
                    withAnimation(){
                        self.storyModel.isShowStory = false
                    }
                    return
                }
                withAnimation{
                    self.storyModel.currentStory = self.storyModel.activeStories[currentSectionIndex - 1].id
                }
            }else {
                self.timeProgress = 0
            }
            return
        }
        
        
        //TODO: Check if the story is the last one(Forward)
        if let last = self.friendInfo.stories_ids.last,last == self.friendInfo.stories_ids[index]{
            //TODO: if there is any other story section,move to the other stroy section else close the story view
            if let lastStory = self.storyModel.activeStories.last,lastStory.id == friendInfo.id{
                withAnimation{
                    self.storyModel.isShowStory = false
                }
                self.timeProgress = 0
            }else {
                let currentSectionIndex = self.storyModel.activeStories.firstIndex(where: {$0.id == friendInfo.id}) ?? 0
                
                withAnimation{
                    self.storyModel.currentStory = self.storyModel.activeStories[currentSectionIndex + 1].id
                }
            }
        }
    }
}

struct UserStoryCardView: View {
    @State private var storyInfo : StoryInfo?
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var userStory : UserStoryViewModel
//    @State private var comment : String = ""
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeProgress : CGFloat = 0

    
    var body: some View {
        GeometryReader{ reader in
            ZStack{
                
                AsyncImage(url: self.storyInfo?.MediaURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }, placeholder: {
                    ProgressView()
                })
                

            }
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
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
                VStack{
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
                    Spacer()
                    HStack{
                        
                        Spacer()
                        HStack{
                            Image(systemName: "ellipsis")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding(8)
//                                .background(Color.black.cornerRadius(25))
                                .contextMenu{
                                    Button {
                                        Task{
                                            if await self.userStory.deleteStory(storyID:self.userStory.currentStoryID){
                                                self.timeProgress = CGFloat(self.userStory.currentStoryIndex)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            
                
                        }
                        .padding(.horizontal,5)
                            
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
                .frame(height: 2)
                .padding(.horizontal)
            })
            .rotation3DEffect(getAngle(proxy: reader), axis: (x:0,y:1,z:0),anchor: reader.frame(in: .global).minX > 0 ? .leading : .trailing,perspective: 2.5)
            .onReceive(self.timer){ t in
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
        .onAppear{
            self.userStory.currentStoryIndex = 0
            self.userStory.currentStoryID = self.userStory.userStories.first!
            Task {
                await getStoryInfo(storyID: self.userStory.currentStoryID)
            }
        }

    }
    
    private func getStoryInfo(storyID : UInt) async {
        let resp = await ChatAppService.shared.GetStoryInfo(storyID: storyID)
        switch resp {
        case .success(let data):
            self.storyInfo = StoryInfo(id: data.story_id, media_url: data.media_url, create_at: data.create_at)
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
    

}
