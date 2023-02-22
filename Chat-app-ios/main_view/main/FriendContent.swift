//
//  FriendContent.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

struct FriendContent: View {
    var body: some View {
        List(dummyContentList) { data in
            FriendRow(data: data)
        }
        .listStyle(.plain)
    }
}

struct FriendContent_Previews: PreviewProvider {
    static var previews: some View {
        FriendContent()
    }
}
