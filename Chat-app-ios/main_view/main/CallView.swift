//
//  CallView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

enum TabItems : String,CaseIterable {
    case Contents = "Friends"
    case Record = "Historys"
}

struct CallView: View {
    @State private var tabs : TabItems = .Contents
    @EnvironmentObject private var userModel : UserViewModel
    var body: some View {
        VStack{
            Picker("", selection: $tabs){
                ForEach(TabItems.allCases,id:\.self){ item in
                    Text(item.rawValue)
                }
            }.pickerStyle(.segmented)
                .padding(.horizontal)
            
            switch tabs {
            case .Contents:
                ScrollView(.vertical,showsIndicators: false){
                    ForEach(self.userModel.friendsList, id: \.id) { data in
                        CallRow(data: data)
                            .padding(.vertical,6)
                            .padding(.horizontal)
                        
                    }
                    
                }
                .onAppear{
                    Task.init{
                        await userModel.GetUserFriendList()
                    }
                }
            case .Record:
                ScrollView(.vertical,showsIndicators: false){
                    VStack{
                        Text("Empty")
                    }
                }
            }
        }
    }
}

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        CallView()
    }
}
