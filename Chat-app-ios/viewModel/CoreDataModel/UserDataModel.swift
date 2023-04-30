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

//
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
            self.rooms = (self.info!.rooms?.allObjects as! [ActiveRooms]).sorted(by: {$0.last_sent_time ?? $0.createdAt! > $1.last_sent_time ?? $1.createdAt!})
            
            return true
        }catch (let err){
            print(err.localizedDescription)
            return false
        }
    }
//
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
        activeRoom.createdAt = Date.now
        self.info?.addToRooms(activeRoom)
        self.fetchUserRoom()
        self.manager.save()
        
        return activeRoom
    }
    
    func addRoomMessage(roomIndex: Int,sender_uuid : String,receiver_uuid:String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,message_type:Int16,sent_at : Date,fileURL : String = "",tempData :Data? = nil,fileName: String,fileSize : Int64,storyAvailabeTime : Int32 = 0, event : MessageEvent) -> RoomMessages {
        
        //TODO: Check Sender Info exist?
        var sender : SenderInfo?
        if content_type != 7{ //SYSTEM_MESSAGE - no need to create
            //MARK: If current is group chat, according to our data structure, sender_id will be the group_id,so we need the recevier_id here
            let id = message_type == 1 ? sender_uuid : event == .send ?  sender_uuid : receiver_uuid
            if let found =  findOneSender(uuid: UUID(uuidString : id)!) {
                sender = found
            }else {
                sender = createOneSenderInfo(uuid: id, avatar: sender_avatar, name: sender_name)
            }
        }
        
        let newMessage = RoomMessages(context: self.manager.context)
        newMessage.id = UUID()
        newMessage.content = content
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
        newMessage.url_path = fileURL
        newMessage.tempData = tempData
        newMessage.file_name = fileName
        newMessage.file_size = fileSize
        newMessage.story_available_time = storyAvailabeTime
        newMessage.sender = sender
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
        print("find sender info :\(uuid.uuidString)")
        let request : NSFetchRequest<SenderInfo> = SenderInfo.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", uuid as CVarArg)
        request.fetchLimit = 1
        guard let sender = try? self.manager.context.fetch(request) else {
            return nil
        }
        return sender.first
    }
    
    func addRoomMessage(sender_uuid : String,receiver_uuid:String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,message_type : Int16,sent_at : Date,fileURL : String = "",fileName: String,fileSize : Int64,storyAvailabeTime : Int32 = 0,event : MessageEvent) -> RoomMessages {
        
        var sender : SenderInfo?
        if content_type != 7{ //SYSTEM_MESSAGE - no need to create
            //MARK: If current is group chat, according to our data structure, sender_id will be the group_id,so we need the recevier_id here
            let id = message_type == 1 ? sender_uuid : event == .send ?  sender_uuid : receiver_uuid
            if let found =  findOneSender(uuid: UUID(uuidString : id)!) {
                sender = found
            }else {
                sender = createOneSenderInfo(uuid: id, avatar: sender_avatar, name: sender_name)
            }
        }

        let newMessage = RoomMessages(context: self.manager.context)
        newMessage.id = UUID()
        newMessage.content = content
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
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
//        let predict = NSPredicate(format: "%K == @", "user",self.info!)
        if let rooms  = self.info?.rooms?.allObjects as? [ActiveRooms] {
            DispatchQueue.main.async {
                self.rooms = rooms.sorted(by: {$0.last_sent_time ?? $0.createdAt! > $1.last_sent_time ?? $1.createdAt!})
              
            }
            
        }
    }
    
    func fetchCurrentRoomMessage(){
        if self.currentRoom == -1 {
            return
        }
        
        if let msg = self.rooms[self.currentRoom].messages?.allObjects as? [RoomMessages] {
            
            DispatchQueue.main.async {
                self.currentRoomMessage = msg.sorted(by: { $0.sent_at! < $1.sent_at! })
            }
        }
    }
    
    func removeAllRoomMessage(room activeRoom : ActiveRooms) -> Bool{
        let predict = NSPredicate(format: "%K == %@", "room" , activeRoom)
        let reqesut = NSFetchRequest<NSFetchRequestResult>(entityName: "RoomMessages")
        reqesut.predicate = predict
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: reqesut)
        
        do {
            try self.manager.context.execute(deleteRequest)
            self.manager.save()
        }catch (let err){
            print(err.localizedDescription)
            return false
        }
        return true
    }
    
    @MainActor
    func removeActiveRoom(room activeRoom : ActiveRooms){
        guard let room = findOneRoom(uuid: activeRoom.id!) else {return }
        guard let index = findOneRoomWithIndex(uuid: activeRoom.id!)  else {
            return
        }
        
        
        self.rooms.remove(at: index)
        self.manager.context.delete(room)
        self.manager.save()
        
    }
    
    
}
