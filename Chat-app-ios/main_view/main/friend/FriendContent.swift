//
//  FriendContent.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

struct FriendContent: View {
    @EnvironmentObject private var userModel : UserViewModel
    var body: some View {
        List {
            ForEach(self.userModel.friendsList,id: \.id) {data in
                FriendRow(data: data)
            }
        }
        .listStyle(.plain)
        .onAppear{
            Task.init {
                await userModel.GetUserFriendList()
            }
        }
    }
}

struct FriendContent_Previews: PreviewProvider {
    static var previews: some View {
        FriendContent()
    }
}
