//
//  StorySeenListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 1/10/2023.
//

import SwiftUI

struct StorySeenListView: View {
    @EnvironmentObject private var storyVM :UserStoryViewModel
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
                
                Image(systemName: "trash")
                    .imageScale(.medium)
                
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

