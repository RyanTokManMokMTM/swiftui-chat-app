//
//  StorySeenListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 1/10/2023.
//

import SwiftUI

struct StorySeenListView: View {
    @StateObject private var hub = BenHubState.shared
    @Binding var isShowSeenList : Bool
    @Binding var isSendMessage :Bool
    @Binding var messageTarget : StorySeenInfo?
    @Binding var timeProgress : CGFloat
    
    @EnvironmentObject private var storyVM :UserStoryViewModel
    
    
    @State private var  isAlert : Bool = false
    var body: some View {
        VStack{
            HStack{
                Image(systemName: "eye")
                    .imageScale(.small)
                
                Text("\(self.storyVM.isLoading ? "--" : self.storyVM.currentStorySeen.description)")
                    .font(.system(size:15))
                    .foregroundColor(.black)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action:{
                    self.isAlert = true
                }) {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .foregroundColor(.black)
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical,8)
            
            Divider()
            
            VStack(alignment:.leading){
                Text("Viewer")
                    .font(.system(size:15))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    .padding(.vertical,8)
                
                List{
                    if self.storyVM.isLoading {
                        ProgressView()
                            .padding(.vertical)
                    }else  {
                        ForEach(self.storyVM.storySeenList, id :\.id) { info in
                            viewUserRow(info: info)
                                .listRowSeparator(.hidden)
                            
                        }
                    }
                }
                .listStyle(.plain)
                
            }
            .padding(.horizontal,0)
            
        }
        .alert(isPresented:$isAlert) {
            Alert(
                title: Text("Delete this story?"),
                message: Text("This will be permanently delete."),
                primaryButton: .destructive(Text("Delete")) {
                    hub.SetWait(message: "Deleting...")
                    Task{
                        if await self.storyVM.deleteStory(storyID:self.storyVM.currentStoryID){
                            hub.isWaiting = false
                            hub.AlertMessage(sysImg: "checkmark", message: "Removed.")
                            self.timeProgress = CGFloat(self.storyVM.currentStoryIndex)
                            self.isShowSeenList = false
                        }
                    }
                },
                secondaryButton: .cancel()
            )
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
    
    @ViewBuilder
    private func viewUserRow(info : StorySeenInfo) -> some View{
        HStack{
            AsyncImage(url: info.AvatarURL, content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:45,height: 45)
                    .clipShape(Circle())
                    .overlay(alignment:.bottomTrailing){
                        if info.is_liked {
                            Image(systemName: "heart.fill")
                                .imageScale(.small)
                                .foregroundColor(.red)
                        }
                    }
                   
            }, placeholder: {
                ProgressView()
                    .frame(width:45,height: 45)
            })
            
            Text(info.name)
                .fontWeight(.medium)
                .font(.system(size:18))
            Spacer()
            
            Button(action:{
                self.messageTarget = info
                withAnimation{
                    self.isSendMessage = true
                }
            }){
                Image(systemName: "paperplane")
                    .imageScale(.large)
                    .foregroundColor(.black)
            }
            .padding(.horizontal,5)

            
        }
        .padding(0)
    }
}

