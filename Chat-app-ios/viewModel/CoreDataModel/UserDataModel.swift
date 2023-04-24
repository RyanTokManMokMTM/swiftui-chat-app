//
//  UserDataModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 14/3/2023.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class UserDataModel : ObservableObject {
    static let shared = UserDataModel()
    let manager = PersistenceController.shared
    @Published var currentRoom : Int = -1
    @Published var info : UserDatas?
    @Published var rooms : [ActiveRooms] = [] 
    @Published var currentRoomMessage : [RoomMessages] = []
    private init(){}

    
    func fetchUserData(id : Int16) -> Bool{
        print(id)
        let predicate = NSPredicate(format: "id == %i", id)
        let request = NSFetchRequest<UserDatas>(entityName: "UserDatas")
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let data = try self.manager.context.fetch(request)
            if data.isEmpty {
                return false
            }
            self.info = data[0]
            self.rooms = self.info!.rooms?.allObjects as! [ActiveRooms]
            return true
        }catch (let err){
            print(err.localizedDescription)
            return false
        }
    }
    
    func addUserData(id : Int16,uuid : String,email : String, name : String, avatar : String){
        let data = UserDatas(context: self.manager.context)
        data.id = id
        data.uuid = UUID(uuidString: uuid)
        data.avatar = avatar
        data.name = name
        data.email = email
        
        self.manager.save()
        self.info = data
    }
    
    func addRoom(id : String,name : String, avatar : String,message_type : Int16) -> ActiveRooms? {
        let activeRoom = ActiveRooms(context: self.manager.context)
        activeRoom.id = UUID(uuidString: id)
        activeRoom.name = name
        activeRoom.avatar = avatar
        activeRoom.message_type = message_type
        self.info?.addToRooms(activeRoom)
        self.fetchUserRoom()
        self.manager.save()
        
        return activeRoom
    }
    
    func addRoomMessage(roomIndex: Int,sender_uuid : String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,sent_at : Date,fileURL : String = "",tempData :Data? = nil,fileName: String? = nil,fileSize : Int64 = 0,storyAvailabeTime : Int32 = 0) -> RoomMessages {
        
        //TODO: Check Sender Info exist?
        var sender = findOneSender(uuid: UUID(uuidString: sender_uuid)!)
        if sender == nil {
//            print("user not found")
            sender = createOneSenderInfo(uuid: sender_uuid, avatar: sender_avatar, name: sender_name)
        }

        
        let newMessage = RoomMessages(context: self.manager.context)
        newMessage.id = UUID()
        newMessage.content = content
//        newMessage.sender_avatar = sender_avatar
//        newMessage.sender_uuid = UUID(uuidString: sender_uuid)!
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
//        newMessage.sender_name = sender_name
        newMessage.url_path = fileURL
        newMessage.tempData = tempData
        newMessage.file_name = fileName
        newMessage.file_size = fileSize
        newMessage.story_available_time = storyAvailabeTime
        newMessage.sender = sender!
        self.rooms[roomIndex].addToMessages(newMessage)
        self.manager.save()
        
        return newMessage
    }
    
    func createOneSenderInfo(uuid : String,avatar : String,name : String) -> SenderInfo{
        let senderUUID = UUID(uuidString: uuid)!
        let senderInfo = SenderInfo(context: self.manager.context)
        senderInfo.id = senderUUID
        senderInfo.avatar = avatar
        senderInfo.name = name
        self.manager.save()

        return senderInfo
    }
    
    func findOneSender(uuid : UUID) -> SenderInfo?{
        let request : NSFetchRequest<SenderInfo> = SenderInfo.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", uuid as CVarArg)
        request.fetchLimit = 1
        guard let sender = try? self.manager.context.fetch(request) else {
            return nil
        }
        return sender.first
    }
    
    func addRoomMessage(sender_uuid : String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,sent_at : Date,fileURL : String = "",fileName: String? = nil,fileSize : Int64 = 0,storyAvailabeTime : Int32 = 0) -> RoomMessages {
        
        var sender = findOneSender(uuid: UUID(uuidString: sender_uuid)!)
        if sender == nil {
//            print("user not found")
            sender = createOneSenderInfo(uuid: sender_uuid, avatar: sender_avatar, name: sender_name)
        }

        let newMessage = RoomMessages(context: self.manager.context)
        newMessage.id = UUID()
        newMessage.content = content
//        newMessage.sender_avatar = sender_avatar
//        newMessage.sender_uuid = UUID(uuidString: sender_uuid)!
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
//        newMessage.sender_name = sender_name
        newMessage.file_name = fileName
        newMessage.file_size = fileSize
        newMessage.story_available_time = storyAvailabeTime
        newMessage.url_path = fileURL
        newMessage.sender = sender
        self.manager.save()
        
        return newMessage
    }

    
    func findOneRoom(uuid : UUID) -> ActiveRooms? {
        if let index = rooms.firstIndex(where: {$0.id == uuid}) {
            return rooms[index]
        }
       
        return nil
    }
    
    func findOneRoomWithIndex(uuid : UUID) -> Int?{
       return rooms.firstIndex(where: {$0.id == uuid})
    }
    
    func fetchUserRoom(){
        if let rooms  = self.info?.rooms?.allObjects as? [ActiveRooms] {
            DispatchQueue.main.async {
                self.rooms = rooms
//                print("fetched.")
            }
           
        }
    }
    
    func fetchCurrentRoomMessage(){
        if self.currentRoom == -1 {
            return
        }
        
        if let msg = self.rooms[self.currentRoom].messages?.allObjects as? [RoomMessages] {
  
            DispatchQueue.main.async {
//                withAnimation{
                    self.currentRoomMessage = msg.sorted(by: { $0.sent_at! < $1.sent_at! })
//                }
                
            }
        }
       
    }
    
    
}
