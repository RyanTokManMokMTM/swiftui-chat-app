//
//  StoryViewer.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 26/8/2023.
//

import SwiftUI

struct StoryViewer: View {
    @Binding var isShowStoryViewer : Bool
    var storyId : UInt
    var friendUUID : String
    
    @EnvironmentObject private var userModel : UserViewModel
    @State private var friendInfo : FriendInfo? = nil
    @State private var isLoading : Bool = false
    var body: some View {
        VStack{
            if self.isLoading {
                ProgressView()
            }else if friendInfo != nil{
                TabView{
                    StoryViwerCard(isShowStoryViewer : $isShowStoryViewer,storyId:storyId,friendInfo: friendInfo)
                        .environmentObject(userModel)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .background(Color.black)
                .transition(.move(edge: .bottom))
            }
        }.onAppear{
            print("\(storyId) \(friendUUID)")
            Task{
                await getFriendInfo()
            }
        }
            
    }
    
    @MainActor
    private func getFriendInfo() async{
        //TO GET FRIEND Story Info
        self.isLoading = true
        let resp = await ChatAppService.shared.GetFriendInfo(friendUUID: self.friendUUID)
        switch(resp){
        case .success(let data):
            DispatchQueue.main.async {
                print(data.friend_info)
                self.friendInfo = data.friend_info
                self.isLoading = false
            }
         
        case .failure(let err):
            print(err.localizedDescription)
            self.isShowStoryViewer = false
        }
    }
}
//
//struct StoryViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryViewer()
//    }
//}
