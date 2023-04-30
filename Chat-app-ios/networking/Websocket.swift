//
//  Websocket.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/3/2023.
//

import Foundation
import Combine

enum MessageEvent {
    case send
    case receive
}

enum ContentType : Int,CaseIterable {
    case text
    case img
    case file
    case audio
    case video
    case story
    case sys
    
    var rawValue: Int {
        switch self{
        case .text : return 1
        case .img : return 2
        case .file : return 3
        case .audio : return 4
        case .video : return 5
        case .story : return 6
        case .sys : return 7
        }
    }
}

struct WSMessage : Codable {
    let avatar : String?
    let fromUserName : String?
    let fromUUID : String?
    let toUUID : String?
    let content : String?
    let contentType : Int16?
    let type : Int16?
    let messageType : Int16?
    
    let urlPath : String?
    let groupName : String?
    let groupAvatar : String?
    let fileName : String?
    let fileSize : Int64?
//    let fileType : String?
//    let file : [UInt8]?
    let storyAvailableTime : Int32?
    

}

class Webcoket : ObservableObject {
    let WS_HOST = "ws://127.0.0.1:8000/ws"
    var session : URLSessionWebSocketTask?
    static var shared = Webcoket()
    
    private var anyCancellable : AnyCancellable? = nil
      
    var userModel : UserViewModel? {
        didSet {
            self.objectWillChange.send()
            anyCancellable = userModel?.objectWillChange.sink(receiveValue: { _ in
//                print("sending???")
                self.objectWillChange.send()
            })
        }
    }
    
    private init(){}
    

    func connect(){
        if self.session != nil {
            print("connection is not nil!")
            return
        }
        
        guard let url = URL(string: WS_HOST) else {
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        self.session = URLSession.shared.webSocketTask(with: request)
        self.session?.receive(completionHandler: self.onReceive(result:))
        self.session?.resume() //continue
        
    }
    
    func disconnect(){
        DispatchQueue.main.async {
            self.session?.cancel()
            self.session = nil
        }
    }
    
    func onReceive(result : Result<URLSessionWebSocketTask.Message, Error>) -> Void {
        self.session?.receive(completionHandler: self.onReceive(result:))
        switch result {
        case.success(let message):
            switch message{
            case .string(let str):
                print("received a string")
                let data = Data(str.utf8)
                
                do {
                    let msg = try JSONDecoder().decode(WSMessage.self, from: data)
                    print(msg)
                } catch(let err) {
                    print(err.localizedDescription)
                }
                
                
            case .data(let data):
                print("received a data")
                print(data)
                do {
                    let msg = try JSONDecoder().decode(WSMessage.self, from: data)
                    print(msg)
                    
                    if let type = msg.type {
                        switch type {
                        case 1:
                            //HEAT_BEAT_PING
                            print("receive a ping message from server")
                            sendPong()
                            break
                        case 2:
                            //HEAT_BEAT_PONG
                            print("receive a pong message from server")
                            break
                        case 3:
                            //SYSTEM MESSAGE
                            print("receive a system message from server")
                            break
                        case 4:
                            //GROUP/PEER/OTHER MESSAGE
                            handleMessage(event: .receive, msg: msg)
                            break
  
                        default:
                            print("UNKNOW TYPE")
                        }
                    }
                } catch(let err) {
                    print(err.localizedDescription)
                }

            @unknown default:
                fatalError()
            }
        case .failure(let err):
            print("received err :\(err.localizedDescription)")
        }
    }

    
    func onSend(msg : WSMessage) {
        print("send message : \(msg)")
        do {
            let req = try JSONEncoder().encode(msg)
            self.session?.send(.data(req)){ err in
                if let err = err {
                    print("send message err \(err.localizedDescription)")
                  
                }
            }
        }catch (let err){
            print(err.localizedDescription)

        }
    }
    
    func sendPong(){
        print("send pong message to server")
        let msg = WSMessage(avatar: nil, fromUserName: nil, fromUUID: nil, toUUID: nil, content: "pong", contentType: nil, type: 2, messageType: nil,urlPath: nil,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil, storyAvailableTime: nil)
        onSend(msg: msg)
    }
    
    func handleMessage(event : MessageEvent,msg : WSMessage ,isReplyComment : Bool = false){
        
        DispatchQueue.main.async { [self] in
//            print("receving a message / sending a message....")
            var roomID : UUID
            
            switch event{
            case .send:
                roomID = UUID(uuidString: msg.toUUID!)!
                break
            case .receive:
                if msg.fromUUID == self.userModel!.profile!.uuid {
                    roomID = UUID(uuidString: msg.toUUID!)!
                    break
                }else {
                    roomID = UUID(uuidString: msg.fromUUID!)!
                    break
                }
            }
            
//            print(msg)
            print(roomID)
            let sentTime = Date.now
            if let index = UserDataModel.shared.findOneRoomWithIndex(uuid: roomID){
//                UserDataModel.shared.rooms[index].unread_message += 1
                if msg.contentType! != ContentType.sys.rawValue {
                    UserDataModel.shared.rooms[index].last_message = msg.contentType == 1 ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
                    UserDataModel.shared.rooms[index].last_sent_time = sentTime
                }
                
                let msg = UserDataModel.shared.addRoomMessage(roomIndex: index, sender_uuid: msg.fromUUID!,receiver_uuid: msg.toUUID!, sender_avatar: msg.avatar ?? "",sender_name: msg.fromUserName ?? "",content: msg.content ?? "",content_type: Int16(msg.contentType!), message_type: msg.messageType!,sent_at:sentTime,fileURL: msg.urlPath ?? "",fileName: msg.fileName ?? "",fileSize: Int64(msg.fileSize ?? 0),storyAvailabeTime: msg.storyAvailableTime ?? 0,event: event)
//                print(msg.sender)
                if UserDataModel.shared.currentRoom == index {
                    UserDataModel.shared.currentRoomMessage.append(msg)
                }else {
                    UserDataModel.shared.rooms[index].unread_message += event == .send ? 0 : 1
                }
                
                UserDataModel.shared.manager.save()
                UserDataModel.shared.fetchUserRoom()
            } else {
                //TODO: what to do if the room is not exist in current client
                if isReplyComment {
//                    print("reply message but not room record")
                    Task {
                        let req = GetUserInfoReq(user_id : nil,uuid: msg.toUUID)
                        let resp = await ChatAppService.shared.GetUserInfo(req: req)
                        switch resp {
                        case .success(let data):
                            let roomName = data.name
                            let roomAvatar = data.avatar
                            if let room = UserDataModel.shared.addRoom(id: data.uuid, name: roomName, avatar: roomAvatar, message_type: msg.messageType!) {
                                room.unread_message = event == .send ? 0 : 1
                                room.last_message = msg.contentType == 1 ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
                                room.last_sent_time = sentTime
                                
                                let msg = UserDataModel.shared.addRoomMessage(sender_uuid: msg.fromUUID!,receiver_uuid:msg.toUUID! ,sender_avatar: msg.avatar ?? "",sender_name: msg.fromUserName ?? "",content: msg.content ?? "",content_type: Int16(msg.contentType!), message_type : msg.messageType!,sent_at:sentTime,fileURL: msg.urlPath ?? "",fileName: msg.fileName ?? "",fileSize: Int64(msg.fileSize ?? 0),storyAvailabeTime: msg.storyAvailableTime ?? 0,event: event)
                                
                                room.addToMessages(msg)
                                
                                UserDataModel.shared.manager.save()
                                UserDataModel.shared.fetchUserRoom()
                                print("message saved.")
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                        
                        
                    }
                }else {
                    let roomName = msg.messageType == 1 ? msg.fromUserName! : msg.groupName!
                    let roomAvatar = msg.messageType == 1 ? msg.avatar! : msg.groupAvatar!
                    if let room = UserDataModel.shared.addRoom(id: msg.fromUUID!, name: roomName, avatar: roomAvatar, message_type: msg.messageType!) {
                        room.unread_message = event == .send ? 0 : 1
                        room.last_message = msg.contentType == 1 ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
                        room.last_sent_time = sentTime
                        
                        let msg = UserDataModel.shared.addRoomMessage(sender_uuid: msg.fromUUID!,receiver_uuid:msg.toUUID! ,sender_avatar: msg.avatar ?? "",sender_name: msg.fromUserName ?? "",content: msg.content ?? "",content_type: Int16(msg.contentType!), message_type : msg.messageType!,sent_at:sentTime,fileURL: msg.urlPath ?? "",fileName: msg.fileName ?? "",fileSize: Int64(msg.fileSize ?? 0),storyAvailabeTime: msg.storyAvailableTime ?? 0,event: event)

                        room.addToMessages(msg)
                        
                        UserDataModel.shared.manager.save()
                        UserDataModel.shared.fetchUserRoom()
                        print("message saved.")
                    }
                    
                }

            }
           
        }
        
    }

    @MainActor
    private func fileConentMessage(fromUUID : String,contentType : Int16) -> String {
        if contentType ==  ContentType.img.rawValue{
           return self.userModel!.profile!.uuid == fromUUID ? "Sent a image." : "Received a image."
        }else if contentType ==  ContentType.file.rawValue {
            return self.userModel!.profile!.uuid == fromUUID ? "Sent a file." : "Received a file."
        }else if contentType ==  ContentType.audio.rawValue {
            return self.userModel!.profile!.uuid == fromUUID ? "Sent a audio" : "Received a audio."
        }else if contentType ==  ContentType.video.rawValue {
            return self.userModel!.profile!.uuid == fromUUID ? "Sent a video" : "Received a video."
        }else if contentType ==  ContentType.story.rawValue{
            return "Reply to a story"
        } else if contentType == ContentType.sys.rawValue {
            return ""
        } else {
            return ""
        }
    }
}
