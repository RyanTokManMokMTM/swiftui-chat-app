//
//  MessageViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import Foundation
import CoreData
class MessageViewModel : ObservableObject {
    init(){}
    @Published var room : ActiveRooms? = nil
    
}

//Store in Client Side
struct ChatInfo : Identifiable {
    let id: String = UUID().uuidString
    let message_type : UInt //1:peer 2 peer 2:group
    let to_id : UInt // UserID or GroupID
    let name : String //groupName or UserName
    let avatar : String // GroupAvatar or User Avatar
    let last_message : String
    let last_sent_time : UInt
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + avatar)!
    }
    
    var LastSentTime : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.last_sent_time))
    }
}

let dummyChatRoom : [ChatInfo] = [
        ChatInfo(message_type: 1, to_id: 1, name: "Joyce", avatar: "/default.jpg",last_message: "hello",last_sent_time: 1678440321),
        ChatInfo(message_type: 2, to_id: 2, name: "FamilyGroup", avatar: "/default2.jpeg",last_message: "hello",last_sent_time: 1678440321),
        ChatInfo(message_type: 2, to_id: 3, name: "Tommy", avatar: "/default2.jpeg",last_message: "hello",last_sent_time: 1678445321),
        ChatInfo(message_type: 1, to_id: 4, name: "Timmy", avatar: "/default.jpg",last_message: "hello",last_sent_time: 1678240321),
        ChatInfo(message_type: 1, to_id: 5, name: "Tom", avatar: "/default.jpg",last_message: "hello",last_sent_time: 1672440321),
        ChatInfo(message_type: 2, to_id: 6, name: "The 5th class", avatar: "/default2.jpeg",last_message: "hello",last_sent_time: 1618440321),
        ChatInfo(message_type: 1, to_id: 7, name: "Jack", avatar: "/default.jpg",last_message: "hello",last_sent_time: 1578440321),
        ChatInfo(message_type: 1, to_id: 8, name: "Angle", avatar: "/default.jpg",last_message: "hello",last_sent_time: 1678440221),
]
