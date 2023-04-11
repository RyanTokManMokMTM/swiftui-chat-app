//
//  SearchView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/3/2023.
//

import SwiftUI

struct SearchView: View {
    @State private var searchKeyWord : String = ""
    @StateObject private var searchModel = SearchViewModel()
    var body: some View {
        VStack{
            Text("Find Friends")
                .bold()
                .font(.headline)
            
            CustomSearchBar(searchKeyWord: $searchKeyWord,placeHoder: "ID/Email"){
                Task.init{
                    await self.searchModel.GetSearchResult(keyword: self.searchKeyWord)
                }
            }
            if self.searchModel.searchResponse.isEmpty {
                Text("No Result.")
            }else {
                List(self.$searchModel.searchResponse,id:\.user_info.id){ $data in
                    NavigationLink(destination: UserContentView(profile: data.user_info, isFriend: $data.is_friend)
                        .accentColor(.white))
                       {
                            UserRow(data: data.user_info, isFriend: data.is_friend)
                    }
                    
                   
                }
                .listStyle(.plain)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func UserRow(data : UserProfile,isFriend : Bool) -> some View {
        HStack(alignment:.center,spacing:12){
            AsyncImage(url: data.AvatarURL, content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:50,height: 50)
                    .clipShape(Circle())
                    
                   
            }, placeholder: {
                ProgressView()
                    .frame(width:50,height: 50)
            })
            
            VStack(alignment:.leading){
                HStack{
                    Text(data.name)
                        .bold()
                        .font(.system(size:20))
                    
                    if isFriend{
                        Image(systemName: "checkmark.circle.fill")
                            .imageScale(.medium)
                            .foregroundColor(.green)
                    }
                }
                
                
//                HStack{
                Text("email : \(data.email)")
                        .bold()
                        .font(.system(size:14))
                        .foregroundColor(.gray)
//                }
            }
            
            Spacer()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
