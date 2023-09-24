//
//  StoryViewrCard.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 26/8/2023.
//

import SwiftUI


struct StoryViwerCard: View {
    @Binding var isShowStoryViewer : Bool
    var storyId : UInt
    var friendInfo : FriendInfo?
    
    @StateObject private var hub = BenHubState.shared
    @State private var storyInfo : StoryInfo?
    @EnvironmentObject private var userModel : UserViewModel
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timeProgress : CGFloat = 0
    
    @State private var isLoadingStoriesList = false
    @State private var storyIds : [UInt] = []
    @State private var index = 0
    @State private var isAction : Bool = false
    @State private var isStoryUnavaiable : Bool = false
    @State private var likeCount = 0
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
                    AsyncImage(url: self.storyInfo?.MediaURL, content: { img in
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
                                    isShowStoryViewer = false
                                }
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
//                            print("front")
                            if (self.timeProgress + 1) > CGFloat(self.storyIds.count) {
                                //Move to other story section
                                withAnimation{
                                    self.isShowStoryViewer = false
                                }
                            }else {
                                //Move to other story in current section
                                self.timeProgress = CGFloat(Int(timeProgress) + 1)
                                self.index = Int(self.timeProgress)
                            }
                        }
                }
            }
            .overlay(alignment:.topTrailing,content: {
                HStack{
                    HStack{
                        AsyncImage(url: self.friendInfo?.AvatarURL ?? URL(string: ""), content: { img in
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
                            Text(self.friendInfo?.name ?? "-")
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
                            self.isShowStoryViewer = false
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
                    ForEach(self.storyIds.indices,id: \.self){ index in
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
                .padding(.horizontal,10)
            })
//            .overlay(alignment:.bottomTrailing){
//                HStack{
//                    HStack{
//                        Button(action:{
////                            self.isAction = true
////                            hub.SetWait(message: "Removing...")
////                            Task{
////                                if await self.userStory.deleteStory(storyID:self.userStory.currentStoryID){
////                                    hub.isWaiting = false
////                                    hub.AlertMessage(sysImg: "checkmark", message: "Removed.")
////                                    self.timeProgress = CGFloat(self.userStory.currentStoryIndex)
////                                    self.isAction = false
////
////
////                                }
////                            }
//                        }){
//                            Image(systemName: "trash")
//                                .imageScale(.medium)
//                                .foregroundColor(.white)
//                                .padding(8)
//
//                        }
//                        
//                    }
//                    .padding(.horizontal,5)
//
//                }
//                .padding(.horizontal)
//            }
            .rotation3DEffect(getAngle(proxy: reader), axis: (x:0,y:1,z:0),anchor: reader.frame(in: .global).minX > 0 ? .leading : .trailing,perspective: 2.5)
            .onReceive(self.timer){ t in
                if self.isAction {
                    return
                }
                //TODO: Update story state
//                if !userStory.isSeen {
//                    userStory.isSeen = true
//                }
//
                if self.timeProgress < CGFloat(storyIds.count){
                    //TODO: for current section
                    self.timeProgress += 0.01
                    self.index = min(Int(self.timeProgress), self.storyIds.count - 1 )
                } else {
                    self.isShowStoryViewer = false
                }
                
 
            }
            .onAppear{
                //TODO: Reset time progress
                self.timeProgress = 0
            }
            .onChange(of: self.index){ id in
                Task{
                    await getStoryInfo(storyID: UInt(self.storyIds[self.index]))
                }
            }
        }
        .overlay(alignment:.bottom){
            HStack{
                Spacer()
                ZStack{
                    EmptyView()
                        .padding(.trailing,30)
                    ForEach(0..<self.likeCount,id:\.self){ _ in
                        Image(systemName: "heart.fill")
                            .imageScale(.large)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .modifier(LoveTapModifier())
                    }
                }
            }
            .padding(.horizontal,10)
            .padding(.bottom,10)
        }
        .onAppear{
            Task {
                await self.getStoriesList(userId: friendInfo!.id)
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
    private func getStoriesList(userId : UInt) async {
        isLoadingStoriesList = true
        self.storyIds = []
        let resp = await ChatAppService.shared.GetUserStories(id: Int(userId))
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.storyIds = data.story_ids
                Task{
                    if data.story_ids.isEmpty {
                        return
                    }
                    
                    if let idx = data.story_ids.firstIndex(where: {$0 == self.storyId}) {
                        self.timeProgress = CGFloat(Int(idx))
                        self.index = idx
                        await self.getStoryInfo(storyID: data.story_ids[idx])
                        
                    }
                    isLoadingStoriesList = false
                   
                }
                
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getStoryInfo(storyID : UInt) async {
        self.likeCount = 0
        let resp = await ChatAppService.shared.GetStoryInfo(storyID: storyID)
        switch resp {
        case .success(let data):
            self.storyInfo = StoryInfo(id: data.story_id, media_url: data.media_url, create_at: data.create_at, is_liked: data.is_liked)
            if data.is_liked {
                self.likeCount = 10
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getStoryIndex() -> Int {
        return min(Int(self.timeProgress),self.storyIds.count - 1)
    }
    
    private func getAngle(proxy : GeometryProxy) -> Angle{
        let progress = proxy.frame(in: .global).minX / proxy.size.width
//        print(progress)
        let degree = CGFloat(45) * progress
//        print("degree : \(degree)")
        return Angle(degrees: Double(degree))
    }

}
