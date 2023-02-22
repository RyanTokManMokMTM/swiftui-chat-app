//
//  CallRow.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 20/2/2023.
//

import SwiftUI

struct CallRow: View {
    let data : ContentUser
    var body: some View {
        HStack(alignment:.center,spacing:12){
            AsyncImage(url: data.avatarURL, content: { img in
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
            
            Button(action: {
                //TODO: Voice Call
            }){
                Image(systemName: "phone.fill")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }
            
            Button(action: {
               //TODO: Video Call
            }){
                Image(systemName: "video.fill")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }
        }
//        .padding(.horizontal,8)
    }
}

struct CallRow_Previews: PreviewProvider {
    static var previews: some View {
        CallRow(data: ContentUser(name: "jackson.tmm", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg"))
    }
}
