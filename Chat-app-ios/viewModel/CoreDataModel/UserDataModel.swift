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
//    @Published var currentRoom : Int = -1
    @Published var currentRoom : ActiveRooms? = nil //or id???
    @Published var info : UserDatas?
    @Published var rooms : [ActiveRooms] = [] 
    @Published var currentRoomMessage : [RoomMessages] = []
    @Published var previousTotalMessage : Int = 0 //for offset correctly
    private init(){}

    //MARK: fetchUserData Fetch current user info from Cache
    func fetchUserData(id : Int16) -> Bool{
//        print(id)
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
    
    //MARK: addUserData Add User Data to Cache
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
    
    //MARK: addRoom Add a new Active Room
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
    
    //MARK: addRoomMessage Add a new messsge of the room to the cache
    func addRoomMessage(room: ActiveRooms,msgID : String,sender_uuid : String,receiver_uuid:String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,message_type:Int16,sent_at : Date,fileURL : String = "",tempData :Data? = nil,fileName: String,fileSize : Int64,storyAvailabeTime : Int32 = 0, event : MessageEvent,messageStatus : MessageStatus) -> RoomMessages {
        
        //TODO: Check Sender Info exist?
        var sender : SenderInfo?
        if content_type != ContentType.sys.rawValue{ //SYSTEM_MESSAGE - no need to create
            //MARK: If current is group chat, according to our data structure, sender_id will be the group_id,so we need the recevier_id here
            let id = message_type == 1 ? sender_uuid : event == .send ?  sender_uuid : receiver_uuid
            if let found =  findOneSender(uuid: UUID(uuidString : id)!) {
                sender = found
            }else {
                sender = createOneSenderInfo(uuid: id, avatar: sender_avatar, name: sender_name)
            }
        }

        let newMessage = RoomMessages(context: self.manager.context)
        newMessage.id = UUID(uuidString: msgID)!
        newMessage.content = content
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
        newMessage.url_path = fileURL
        newMessage.tempData = tempData
        newMessage.file_name = fileName
        newMessage.file_size = fileSize
        newMessage.story_available_time = storyAvailabeTime
        newMessage.sender = sender
        newMessage.message_status = messageStatus.rawValue
        room.addToMessages(newMessage)
        self.manager.save()
        
        return newMessage
    }
    
    //MARK: createOneSenderInfo Create One Sender Info to cache
    func createOneSenderInfo(uuid : String,avatar : String,name : String) -> SenderInfo{
        let senderUUID = UUID(uuidString: uuid)!
        let senderInfo = SenderInfo(context: self.manager.context)
        senderInfo.id = senderUUID
        senderInfo.avatar = avatar
        senderInfo.name = name
        self.manager.save()

        return senderInfo
    }
    
    //MARK: findOneSender Find One Sender in cache
    func findOneSender(uuid : UUID) -> SenderInfo?{
        let request : NSFetchRequest<SenderInfo> = SenderInfo.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", uuid as CVarArg)
        request.fetchLimit = 1
        guard let sender = try? self.manager.context.fetch(request) else {
            return nil
        }
        return sender.first
    }
    
    //MARK: addRoomMessage Add a new message to Room
    func addRoomMessage(msgID : String,sender_uuid : String,receiver_uuid:String,sender_avatar : String,sender_name : String,content : String,content_type : Int16,message_type : Int16,sent_at : Date,fileURL : String = "",fileName: String,fileSize : Int64,storyAvailabeTime : Int32 = 0,event : MessageEvent,messageStatus : MessageStatus) -> RoomMessages {
        
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
        newMessage.id = UUID(uuidString: msgID)!
        newMessage.content = content
        newMessage.sent_at = sent_at
        newMessage.content_type = content_type
        newMessage.file_name = fileName
        newMessage.file_size = fileSize
        newMessage.story_available_time = storyAvailabeTime
        newMessage.url_path = fileURL
        newMessage.sender = sender
        newMessage.message_status = messageStatus.rawValue
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
        guard let room = self.currentRoom  else {
            return
        }
        if !hasMoreMessage() {
            return
        }
        
        
        let count = self.currentRoomMessage.count
        let predict = NSPredicate(format: "%K == %@", "room" , room)
        let req = RoomMessages.fetchRequest()
        let sortBySentTime = NSSortDescriptor(key:"sent_at", ascending:false)
        req.fetchLimit = 20
        req.predicate = predict
        req.sortDescriptors = [sortBySentTime]
        req.fetchOffset = count
        do {
            let data = try self.manager.context.fetch(req)
            DispatchQueue.main.async {
                    self.currentRoomMessage.insert(contentsOf: data.reversed(), at: 0)
            }
          
        } catch (let err){
            print(err.localizedDescription)
        }

    }
    
    func hasMoreMessage() -> Bool {
        let count = self.currentRoomMessage.count
        return (self.previousTotalMessage - count) > 0
    }
    
    func getMessageCount(room : ActiveRooms){
        let req = RoomMessages.fetchRequest()
        let predict = NSPredicate(format: "%K == %@", "room" , room)
        req.predicate = predict
        
        do {
            let count = try self.manager.context.count(for: req)
            self.previousTotalMessage = count
        }catch (let err){
            print(err.localizedDescription)
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
    
    func findOneMessage(id : UUID) -> RoomMessages?{
        let request : NSFetchRequest<RoomMessages> = RoomMessages.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        request.fetchLimit = 1
        guard let message = try? self.manager.context.fetch(request) else {
            return nil
        }
        return message.first
    }
    
    @MainActor
    func updateMessageStatus(msg : RoomMessages, status : MessageStatus) {
        msg.message_status = status.rawValue
        self.manager.save()
    }
    
    
    @MainActor
    func deleteMessage(msg : RoomMessages,content : String) {
        msg.room!.last_message = content
        msg.room!.unread_message -= msg.room!.unread_message > 0 ? 1 : 0
        msg.deleted_at = Date.now
        msg.content = content
        msg.url_path = nil
        msg.file_name = nil
        msg.file_size = 0
        msg.content_type = ContentType.sys.rawValue
        self.manager.save()
    }
    
    
    
}

