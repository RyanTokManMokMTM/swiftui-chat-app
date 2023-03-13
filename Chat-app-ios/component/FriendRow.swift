//
//  FriendRow.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

struct FriendRow: View {
    let data : UserProfile
    var body: some View {
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
            
            Text(data.name)
                .bold()
                .font(.system(size:18))
            
            Spacer()
        }
    }
}

//struct FriendRow_Previews: PreviewProvider {
//    static var previews: some View {
//        FriendRow(data: ContentUser(name: "jackson.tmm", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg"))
//    }
//}

struct ContentUser : Identifiable {
    let id = UUID().uuidString
    let name : String
    let avatar : String
    
    var avatarURL : URL {
        return URL(string: avatar)!
    }
}
