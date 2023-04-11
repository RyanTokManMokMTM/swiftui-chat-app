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
    let fileSize : Int16?
//    let fileType : String?
//    let file : [UInt8]?

}


final class Webcoket {
    let WS_HOST = "ws://127.0.0.1:8000/ws"
    var session : URLSessionWebSocketTask?
    static var shared = Webcoket()
    
    private var anyCancellable : AnyCancellable? = nil
    var userModel : UserViewModel? {
        didSet {
            self.userModel?.objectWillChange.send()
            anyCancellable = userModel?.objectWillChange.sink(receiveValue: { _ in
                self.userModel?.objectWillChange.send()
            })
        }
    }
    
    private init(){}
    

    func connect(){
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
//                print(data)
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
        let msg = WSMessage(avatar: nil, fromUserName: nil, fromUUID: nil, toUUID: nil, content: "pong", contentType: nil, type: 2, messageType: nil,urlPath: nil,groupName: nil,groupAvatar: nil,fileName: nil,fileSize: nil)
        onSend(msg: msg)
    }
    
    func handleMessage(event : MessageEvent,msg : WSMessage){
        print(msg)
        DispatchQueue.main.async { [self] in
            print("receving a message / sending a message....")
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
            
            let sentTime = Date.now
            if let index = UserDataModel.shared.findOneRoomWithIndex(uuid: roomID){
//                UserDataModel.shared.rooms[index].unread_message += 1
                UserDataModel.shared.rooms[index].last_message = msg.contentType == 1 ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
                UserDataModel.shared.rooms[index].last_sent_time = sentTime
                
                let msg = UserDataModel.shared.addRoomMessage(roomIndex: index, sender_uuid: msg.fromUUID!, sender_avatar: msg.avatar!,sender_name: msg.fromUserName!,content: msg.content ?? "",content_type: Int16(msg.contentType!), sent_at:sentTime,fileURL: msg.urlPath ?? "")
                
                if UserDataModel.shared.currentRoom == index {
                    UserDataModel.shared.currentRoomMessage.append(msg)
                }else {
                    UserDataModel.shared.rooms[index].unread_message += 1
                }
                
                UserDataModel.shared.manager.save()
                UserDataModel.shared.fetchUserRoom()
            } else {
                //TODO: what to do if the room is not exist in current client
              
                let roomName = msg.messageType == 1 ? msg.fromUserName! : msg.groupName!
                let roomAvatar = msg.messageType == 1 ? msg.avatar! : msg.groupAvatar!
                if let room = UserDataModel.shared.addRoom(id: msg.fromUUID!, name: roomName, avatar: roomAvatar, message_type: msg.messageType!) {
                    room.unread_message = 1
                    room.last_message = msg.contentType == 1 ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
                    room.last_sent_time = sentTime
                    
                    let msg = UserDataModel.shared.addRoomMessage(sender_uuid: msg.fromUUID!, sender_avatar: msg.avatar!,sender_name: msg.fromUserName!,content: msg.content ?? "",content_type: Int16(msg.contentType!), sent_at:sentTime,fileURL: msg.urlPath ?? "")
                    
                    room.addToMessages(msg)
                    
                    UserDataModel.shared.manager.save()
                    UserDataModel.shared.fetchUserRoom()
                    print("message saved.")
                }
                
            }
           
        }
        
    }
    
    private func fileConentMessage(fromUUID : String,contentType : Int16) -> String {
        return self.userModel!.profile!.uuid == fromUUID ? "[Sent a \(contentType == 2 ? "image" : "file")]" : "[Received a \(contentType == 2 ? "image" : "file")]"
    }
}
