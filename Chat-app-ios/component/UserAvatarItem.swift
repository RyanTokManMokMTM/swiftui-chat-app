//
//  UserAvatarItem.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/2/2023.
//

import SwiftUI

struct UserAvatarItem: View {
    let avatarURL : URL
//    let isActive : Bool
    let isRead : Bool
    var body: some View {
        VStack{
            AsyncImage(url: avatarURL, content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:65,height: 65)
                    .clipShape(Circle())
                   
            }, placeholder: {
                ProgressView()
                    .frame(width:65,height: 65)
            })
        }
        .frame(width: 80,height: 80)
        .clipShape(Circle())
        .overlay{
//            if isActive {
                if !self.isRead {
                    Circle()
                        .strokeBorder(LinearGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), startPoint: .bottom, endPoint: .top),lineWidth: 3)
                }else {
                    Circle()
                        .strokeBorder(Color(uiColor: .systemGray4),lineWidth: 3)
                }
//                Circle()
                    
//            }
        }
    }
}

struct UserAvatarItem_Previews: PreviewProvider {
    static var previews: some View {
        UserAvatarItem(avatarURL: URL(string: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg")!, isRead: true)
    }
}
