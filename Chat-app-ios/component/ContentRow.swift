//
//  ContentRow.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/2/2023.
//

import SwiftUI

struct ContentRow: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var data : ActiveRooms
    var body: some View {
        HStack(alignment:.top,spacing:10){
            AsyncImage(url: data.AvatarURL, content: { img in
               img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:50,height: 50)
                    .clipShape(Circle())
//                    .overlay(alignment: .bottomTrailing) {
//                        //not read and sender exist and not sender
//                        if data.message_type == 1 {
//                            Circle()
//                                .foregroundColor(data.isOnline ? .green : .clear)
//                                .frame(width: 15, height: 15)
//                        }
////                        Circle()
////                            .foregroundColor(data.isOnline ? .green : .clear)
////                            .frame(width: 15, height: 15)
//                    }
                    
                    
                
            }, placeholder: {
                ProgressView()
                    .frame(width:50,height: 50)
            })
            
            HStack(alignment:.bottom){
                VStack(alignment:.leading,spacing:5){
                    HStack{
                        Text(data.name ?? "UNKNOW CHAT")
                            .bold()
                            .font(.system(size: 20))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                        
                        if data.IsUnreal {
                            Circle()
                                .fill(.blue)
                                .frame(width: 22)
                                .overlay{
                                    Text(data.unread_message.description)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        
                                }
                        }
                       
                    }
                    
                    HStack(spacing:13){
                        Text(data.last_message ?? "")
                            .lineLimit(1)
                            .font(.system(size:15))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            Spacer()
                        VStack{
                            Text(data.last_sent_time?.sendTimeString() ?? "")
                                .foregroundColor(.gray)
                                .font(.system(size: 15))
                        }
                    }
                    .font(.system(size:18))
                }
                
        
            }
        
        }
//        .padding(.horizontal)
        .frame(maxWidth: .infinity,maxHeight: 60)
        
    }
}

//struct ContentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentRow(data: ContentInfo(id : 1,name: "Testing", avatar: "https://i.ibb.co/zf5XCDm/3fef478737ea0f4abe5d69db3e25d71e.jpg", lastMessage: "hello, my name is jackson,where are you", lastSent: Calendar.current.date(byAdding: .day, value: 0, to: .now)!, isOnline: true))
//    }
//}
