//
//  StoryCardView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

struct LoveTapModifier: ViewModifier {
    
    @State var time = 0.0
    let duration = 3.0
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.red)
                .modifier(LoveGeometryEffect(time: time))
                .opacity(time == 3 ? 0 : 1)
        }
        
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
            }
        }
    }
}


struct LoveGeometryEffect : GeometryEffect {
    var time : Double
    var speed = 150.0
    var xDirection = Double.random(in:  -0.1 ... 0.1)
    var yDirection = Double.random(in: -Double.pi ...  0)
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * xDirection
        let yTranslation = speed * sin(yDirection) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
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
    
    @State private var isLoadingStoriesList = false
    @State private var stories : [BasicStoryInfo] = []
//    @State private var isLiked : Bool = false
    @State private var likeCount = 0
    @State private var isStoryUnavaiable : Bool = false
    @StateObject private var hub = BenHubState.shared
    
    @State private var isShareToFriend : Bool = false
    var body: some View {
        GeometryReader{ reader in
            ZStack{
                if isLoadingStoriesList{
                    ProgressView()
                        .background(Color.black)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .center)
                        .cornerRadius(10)
                        .clipped()
                }else if isStoryUnavaiable {
                    VStack{
                        Text("Story Unavailable.")
                            .foregroundColor(.white)
                    }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .center)
                        .cornerRadius(10)
                        .clipped()
                }else {
                    AsyncImage(url: story?.MediaURL, content: { img in
                        VStack{
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .top)
                                .cornerRadius(10)
                                .clipped()
                        }
    //                    .padding(.horizontal)
                    }, placeholder: {
                        ProgressView()
                            
                    })
                }

//                .frame(height:UIScreen.main.bounds.height)
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
            .overlay{
                HStack(spacing:0){
                    //TODO: Tap on left -> moving backward
                    Rectangle()
                        .fill(.black.opacity(0.1))
                        .onTapGesture {
//                            self.isLiked = false
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
                            if (self.timeProgress + 1) > CGFloat(self.stories.count) {
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
            .overlay{
                if self.isFocus{
                    Color.black.opacity(0.65).edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isFocus = false
                            self.comment.removeAll()
                        }
                } else if isShareToFriend {
                    Color.black.opacity(0.65).edgesIgnoringSafeArea(.all)
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
                                
                                Text(story?.CreatedTime.hourBetween() ?? "")
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
                    .padding()
                    
                    Spacer()
                }
               
            } //the close button
            .overlay(alignment:.top,content: {
                VStack{
                    HStack(spacing:3){
                        //MARK: Story Time line
                        ForEach(self.stories.indices,id:\.self){ index in
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
                   
                    
                    Spacer()
                }
                .padding(.horizontal,10)
            })
            .rotation3DEffect(getAngle(proxy: reader), axis: (x:0,y:1,z:0),anchor: reader.frame(in: .global).minX > 0 ? .leading : .trailing,perspective: 2.5)
            .onReceive(self.timer){ t in
                if isFocus || isShareToFriend{
                    return
                }
                if storyModel.currentStory == friendInfo.id {
                    //TODO: Update story state
                    if !friendInfo.is_seen {
                        friendInfo.is_seen = true
                    }
                    
                    if self.timeProgress < CGFloat(self.stories.count){
                        //TODO: for current section
                        self.timeProgress += 0.01
                        self.index = min(Int(self.timeProgress), self.stories.count - 1 )
                    } else {
                        updateStory(isForward: true)
                        //MARK: To dismiss
                    }
                }
            }
            
            .onAppear{
                self.timeProgress = 0
            }
        }
        .sheet(isPresented: $isShareToFriend){
            if let storyInfo = self.story {
                StoryShareView(isActive: $isShareToFriend,storyUserInfo: self.friendInfo, storyInfo: storyInfo)
                    .onAppear{
                        Task{
                           await self.storyModel.GetUserFriendList()
                        }
                      
                    }
                    .environmentObject(storyModel)
                    .padding(.top)
                    .presentationDetents([.medium, .large])
            }
        
               
        }
        .overlay(alignment:.bottom){
            if !isStoryUnavaiable {
                HStack{
                    VStack{
                        TextField(text: $comment) {
                            Text("Reply to \(friendInfo.name)")
                                .foregroundColor(.white)
                                .font(.system(size:14))
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
                            .stroke(.gray.opacity(0.8), lineWidth: 1.5)
                    ))
                    
//
                    
                    if !self.isFocus {
                        ZStack{
                            Button(action:{
                                //TODO: DO Nothing right now
                                if self.story != nil {
                                    if !self.story!.is_liked {
                                        Task{
                                            await self.createStoryLike(storyId: self.story!.id)
                                        }
                                    }else{
                                        Task{
                                            await self.deleteStoryLike(storyId: self.story!.id)
                                        }
                                    }
                                }
                                
                               
                            }){
                                Image(systemName: self.story?.is_liked ?? false  ? "heart.fill" : "heart")
                                    .imageScale(.large)
                                    .fontWeight(.medium)
                                    .foregroundColor(self.story?.is_liked ?? false ? .red : .white)
                            }
                            
                            ForEach(0..<self.likeCount,id:\.self){ _ in
                                Image(systemName: "heart.fill")
                                    .imageScale(.large)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                    .modifier(LoveTapModifier())
                            }
                        }
                        
                        Button(action:{
                            //TODO: DO Nothing right now
                            withAnimation{
                                self.isShareToFriend = true
                            }
                        }){
                            Image(systemName: "paperplane")
                                .imageScale(.large)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                
                        }
                        
                    }
                   
                    
                }
                .padding(.horizontal,10)
                .padding(.bottom,10)
            }
        }
        .onChange(of: self.index){ i in
            Task {
                self.isStoryUnavaiable = false
                await self.getStoryInfo(storyID: UInt(self.stories[i].story_id))
                await self.updateStorySeen(storyId: UInt(self.stories[i].story_id))
                
            }
        }
        .onAppear{
            Task {
                await self.getStoriesList(userId: friendInfo.id)
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
    
    private func replyStory() async{
        if comment.isEmpty || self.isStoryUnavaiable{
            return
        }
        let sendMsg = WSMessage(
            messageID: UUID().uuidString,
            replyMessageID: nil, avatar: self.userModel.profile!.avatar,
            fromUserName: self.userModel.profile!.name,
            fromUUID: self.userModel.profile!.uuid,
            toUUID: self.friendInfo.uuid,
            content: self.comment,
            contentType: ContentType.STORY.rawValue,
            eventType: EventType.MESSAGE.rawValue,
            messageType: 1,
            urlPath: self.story!.media_url,
            fileName: nil,
            fileSize: nil,
            contentAvailableTime: Int32(self.story!.create_at),
            contentUUID: self.story!.uuid,
            contentUserName: self.friendInfo.name,
            contentUserAvatar: self.friendInfo.avatar,
            contentUserUUID: self.friendInfo.uuid
        )
        Websocket.shared.handleMessage(event:.send,msg: sendMsg,isGetRoomUserInfo: true){
            hub.AlertMessage(sysImg: "checkmark", message: "Replied")
        }

        
        self.comment.removeAll()
        
    }
    
    private func getStoryInfo(storyID : UInt) async {
//        print(storyID)
        self.likeCount = 0
        self.story = nil
        let resp = await ChatAppService.shared.GetStoryInfo(storyID: storyID)
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.story = StoryInfo(id: data.story_id, uuid: data.story_uuid ,media_url: data.media_url, create_at: data.create_at, is_liked: data.is_liked,story_seen_list: data.story_seen_list)
                if data.is_liked {
                    self.likeCount = 10
                }
            }
        case .failure(let err):
            self.isStoryUnavaiable = true
            print(err.localizedDescription)
            
        }
    }
    
    private func getStoriesList(userId : UInt) async {
        isLoadingStoriesList = true
        self.stories = []
        let resp = await ChatAppService.shared.GetUserStories(id: Int(userId))
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.stories = data.stories
                isLoadingStoriesList = false
                Task{
//                    print(data)
                    if data.stories.isEmpty {
                        return
                    }
                    
                    if let foundIndex = data.stories.firstIndex(where: {$0.story_id >= data.last_story_id}){
                        self.index = min(foundIndex,data.stories.count - 1)
                        self.timeProgress = CGFloat(min(foundIndex,data.stories.count - 1))
                    }else if let foundIndex = data.stories.lastIndex(where: {$0.story_id < data.last_story_id}){
                        self.index = max(foundIndex,0)
                        self.timeProgress = CGFloat(max(foundIndex,0))
                    }
                    if self.index == 0{
                        await self.getStoryInfo(storyID: data.stories.first!.story_id)
                        await self.updateStorySeen(storyId: data.stories.first!.story_id)
                    }
                }
                
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func createStoryLike(storyId : UInt) async {
        let req = CreateStoryLikeReq(story_id: storyId)
        let resp = await ChatAppService.shared.CreateStoryLike(req: req)
        switch(resp){
        case .success(_):
            DispatchQueue.main.async {
                if self.story != nil {
                    withAnimation{
                        self.story!.is_liked = true
                        self.likeCount = 10
                    }
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func deleteStoryLike(storyId : UInt) async {
        let req = DeleteStoryLikeReq(story_id: storyId)
        let resp = await ChatAppService.shared.DeleteStoryLike(req: req)
        switch(resp){
        case .success(_):
            DispatchQueue.main.async {
                if self.story != nil {
                    withAnimation{
                        self.story!.is_liked = false
                        self.likeCount = 0
                    }
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getStoryIndex() -> Int {
        return min(Int(self.timeProgress),self.storyModel.activeStories.count - 1)
    }
    
    private func updateStorySeen(storyId : UInt) async{
        let req = UpdateUserStorySeenReq(friend_id: self.friendInfo.id, story_id: storyId)
        let resp = await ChatAppService.shared.UpdateStorySeen(req: req)
        switch(resp){
        case .success(_): break
        case .failure(let err):
            print(err.localizedDescription)
        }
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
        if let last = self.stories.last,last.story_id == self.stories[index].story_id{
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

