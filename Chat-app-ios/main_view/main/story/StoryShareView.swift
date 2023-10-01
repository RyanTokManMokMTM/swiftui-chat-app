//
//  StoryShareView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 30/9/2023.
//

import SwiftUI



struct StoryShareView: View {
    @EnvironmentObject private var storyModel : StoryViewModel
    @Binding var isActive : Bool
    @State private var searchText : String = ""
    @FocusState private var isFocus : Bool
    
    @State private var toShareList : [UInt] = []
    var body: some View {
        VStack(spacing: 5) {
            HStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .imageScale(.medium)
                    TextField("Search ...", text: $searchText)
                        .focused($isFocus)
                        .submitLabel(.search)
                    
                    if isFocus && !self.searchText.isEmpty {
                        Button(action: {
                            searchText.removeAll()
                        }) {
                            Image(systemName: "xmark")
                                .imageScale(.small)
                                .foregroundColor(.white)
                                .scaleEffect(0.8)
                                .padding(3)
                                .background(){
                                    Color.gray.clipShape(Circle())
                                }
                                
                        }
                        .transition(.opacity)
                        .animation(.default)
            
                    }
                  
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)


                
                if isFocus {
                    Button(action: {
                        isFocus = false
                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
                
                
            }

            
            List{
                if self.storyModel.isLoading {
                    ProgressView()
                        .padding()
                }else if self.storyModel.friendsList.isEmpty{
                    Text("No Result")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ForEach(self.$storyModel.friendsList,id:\.profile.id){ info in
                        ShareFriendRow(data: info, shareList: $toShareList)
                            .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)

            HStack{
                Button(action: {
                    
                }){
                    HStack{
                        Spacer()
                        Text("Send")
                            .foregroundColor( .white)
                            .font(.system(size:15))
                            .padding(.horizontal)
                            .padding(.vertical,8)
                            
                        Spacer()
                    }
                    .background(toShareList.isEmpty ? .gray : .blue)
                    .cornerRadius(10)
                    
                }
                .disabled(toShareList.isEmpty)
                .padding()
            }

            
        }
        .onChange(of: self.searchText){ text in
            Task {
               await self.storyModel.GetSearchResult(keyword: text)
            }
        }
    }
    
}



struct ShareFriendRow: View {
    @Binding var data : ShareUserProfile
    @Binding var shareList : [UInt]
    var body: some View {
        Button(action:{
            withAnimation{
                self.data.isSelected.toggle()
                if self.data.isSelected{
                    self.shareList.append(data.profile.id)
                }else {
                    if let index = self.shareList.firstIndex(where: { $0 == data.profile.id}) {
                        self.shareList.remove(at: Int(index))
                    }
                }
            }
        }) {
            HStack(alignment:.center,spacing:12){
                AsyncImage(url: data.profile.AvatarURL, content: { img in
                   img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:45,height: 45)
                        .clipShape(Circle())
                       
                }, placeholder: {
                    ProgressView()
                        .frame(width:45,height: 45)
                })
                
                Text(data.profile.name)
                    .fontWeight(.medium)
                    .font(.system(size:18))
                
                Spacer()
                
                if self.data.isSelected {
                    Circle()
                        .fill(.green)
                        .frame(width:20,height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                                .foregroundColor(.white)
                        )
                        .padding(.trailing,5)
                }else {
                    Circle()
                        .stroke(lineWidth: 1)
                        .fill(.gray)
                        .frame(width:20,height: 20)
                        .padding(.trailing,5)
                }
                        
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

    }
    
   
}

