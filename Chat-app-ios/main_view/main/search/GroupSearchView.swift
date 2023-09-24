//
//  GroupSearch.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/4/2023.
//

import SwiftUI

struct GroupSearchView: View {
    @State private var searchKeyWord : String = ""
    @StateObject private var searchModel = SearchGroupViewModel()
    var body: some View {
        VStack{
            Text("Find a group")
                .bold()
                .font(.headline)
            
            CustomSearchBar(searchKeyWord: $searchKeyWord,placeHoder: "Group Name"){
                Task.init{
                    await self.searchModel.GetSearchResult(keyword: self.searchKeyWord)
                }
            }
            if self.searchModel.searchResponse.isEmpty {
                Text("No Result.")
            }else {
                List(self.$searchModel.searchResponse,id:\.id){ data in
                    NavigationLink(destination: SearchGroupProfileResultView(info: data)
                        .accentColor(.white))
                       {
                           GroupRow(data: data.wrappedValue)
                    }
                }
                .listStyle(.plain)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private func GroupRow(data : FullGroupInfo) -> some View {
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
                        .lineLimit(1)
                }
                
                
//                HStack{
                Text("members : \(data.members)")
                        .bold()
                        .font(.system(size:14))
                        .foregroundColor(.gray)
//                }
            }
            
            Spacer()
        }
    }
}

struct GroupSearchView_Previews: PreviewProvider {
    static var previews: some View {
        GroupSearchView()
    }
}
