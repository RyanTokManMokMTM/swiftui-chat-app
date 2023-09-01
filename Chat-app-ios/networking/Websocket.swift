//
//  Websocket.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/3/2023.
//

import Foundation
import Combine
import WebRTC

enum MessageEvent {
    case send
    case receive
}

//
//enum SocketMessageType : Int16{
//    case PING
//    case PONG
//    case SYSTEM
//    case MESSAGE
//    case RTC
//    case MESSAGE_ACK
//
//    var rawValue: Int16{
//        switch self {
//        case .PING : return 1
//        case .PONG : return 2
//        case .MESSAGE : return 3
//        case .RTC : return 4
//
//        }
//    }
//
//}

enum ContentType : Int16,CaseIterable {
    case text
    case img
    case file
    case audio
    case video
    case story
    case sys
    case msgReply
    case sticker

    
    var rawValue: Int16 {
        switch self{
        case .text : return 1
        case .img : return 2
        case .file : return 3
        case .audio : return 4
        case .video : return 5
        case .story : return 6
        case .sys : return 7
        case .msgReply : return 8
        case .sticker : return 9
        }
    }
}

struct WSMessage : Codable {
    let messageID : String?
    let avatar : String?
    let fromUserName : String?
    let fromUUID : String?
    let toUUID : String?
    let content : String?
    let contentType : Int16?
    let type : Int16?
    let messageType : Int16?
    
    let urlPath : String?
    let fileName : String?
    let fileSize : Int64?
    let storyAvailableTime : Int32?
    let replyMessageID : String?
    let storyId : Int16?

}

protocol WebSocketDelegate : class {
    func webSocket(_ webSocket: Websocket, didReceive data: WSMessage)
    func webSocket(_ webSocket: Websocket, didConnected data: Bool)
}

class Websocket : ObservableObject {
    var session : URLSessionWebSocketTask?
    static var shared = Websocket()
    
    private var anyCancellable : AnyCancellable? = nil
    var delegate : WebSocketDelegate?
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
    
    func reset(){
        self.disconnect()
        self.userModel = nil
    }
    
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
        self.delegate?.webSocket(self, didConnected: true)
    }
    
    func disconnect(){
        DispatchQueue.main.async {
            self.session?.cancel()
            self.session = nil
            
        }
    }
    
    
    @MainActor
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

                } catch(let err) {
                    print(err.localizedDescription)
                }
                
                
            case .data(let data):
//                print("received a data")
                print(data)
                do {
                    let msg = try JSONDecoder().decode(WSMessage.self, from: data)
//                    print(msg)
                    
                    if let type = msg.type {
                        switch type {
                        case 1:
                            sendPong()
                            break
                        case 2:
                            break
                        case 3:
                            break
                        case 4:
                            handleMessage(event: .receive, msg: msg)
                            break
                        case 5:
                            self.delegate?.webSocket(self, didReceive: msg) //TODO: VideoCall VM handel this.
                            break
                        case 6:
                            guard let id = msg.messageID else {
                                break
                            }
                            print("ack :\(id)")
                            updateMessageStatus(messsageID: id)
                            break
                        case 7:
                            print("recall message")
                            updateMessage(wsMSG: msg)
                            //Find the message and update the message
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
            self.delegate?.webSocket(self, didConnected: false)
        }
    }
    
    
    func onSend(msg : WSMessage) {
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
        let msg = WSMessage(messageID: nil, avatar: nil, fromUserName: nil, fromUUID: nil, toUUID: nil, content: "pong", contentType: nil, type: 2, messageType: nil,urlPath: nil,fileName: nil,fileSize: nil, storyAvailableTime: nil,replyMessageID: nil, storyId: nil)
        onSend(msg: msg)
    }
    
    @MainActor
    func handleMessage(event : MessageEvent,msg : WSMessage ,isReplyComment : Bool = false){
        DispatchQueue.main.async { [self] in
            var roomID : UUID
            var GroupRoomName : String = ""
            var GroupRoomAvatar : String = ""
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
            let messageID = msg.messageID ?? UUID().uuidString
            if let room = UserDataModel.shared.findOneRoom(uuid: roomID) {
                addNewMessageToRoomCache(msg: msg, room: room, messageID: messageID, sentTime: sentTime, event: event, storyId: msg.storyId ?? 0)
                if msg.messageType == 2 {
                    GroupRoomName = room.name!
                    GroupRoomAvatar = room.avatar!
                }
  
            } else{
                //TODO: what to do if the room is not exist in current client
                if isReplyComment {
                    Task {
                        let req = GetUserInfoReq(user_id : nil,uuid: msg.toUUID)
                        let resp = await ChatAppService.shared.GetUserInfo(req: req)
                        switch resp {
                        case .success(let data):
                            let roomName = data.name
                            let roomAvatar = data.avatar
                            addNewRoomToCache(roomUUID: roomID, msg: msg, roomName: roomName, roomAvatar: roomAvatar, event: event, sentTime: sentTime, messageID: messageID, storyId: msg.storyId ?? 0)
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }else {
                    if msg.messageType == 2 {
                        Task{
                            let resp = await ChatAppService.shared.GetGroupInfoByUUID(uuid:roomID.uuidString.lowercased())
                            switch resp {
                            case .success(let data):
                                GroupRoomName = data.result.name
                                GroupRoomAvatar = data.result.avatar
                                addNewRoomToCache(roomUUID: roomID, msg: msg, roomName: GroupRoomName, roomAvatar: GroupRoomAvatar, event: event, sentTime: sentTime, messageID: messageID, storyId:  msg.storyId ?? 0)
                            case .failure(let err):
                                print(err.localizedDescription)
                                return
                            }
                        }
                    }else {
                        addNewRoomToCache(roomUUID: roomID, msg: msg, roomName: msg.fromUserName!, roomAvatar: msg.avatar!, event: event, sentTime: sentTime, messageID: messageID, storyId:  msg.storyId ?? 0)
                    }

                }

                
            }
            
            if event == .receive{
            
                sendAck(messageID: msg.messageID!,  formUUID: self.userModel!.profile!.uuid)
                playReceivedMessageSound()
                
                
                if UserDataModel.shared.currentRoom == nil || UserDataModel.shared.currentRoom!.id!.uuidString.lowercased() != roomID.uuidString.lowercased(){
                    if msg.messageType == 1 {
                        
                        let notifyMessage : String
                        if msg.contentType == ContentType.text.rawValue{
                            notifyMessage = "\(msg.content!)"
                        }else if msg.contentType == ContentType.msgReply.rawValue {
                            notifyMessage = "Reply to a meesage : \(msg.content!)"
                        }else {
                            notifyMessage = "\(notificationConentMessage(fromUUID: msg.fromUserName!, contentType: msg.contentType!))"
                        }
                        
                        BenHubState.shared.AlertMessageWithUserInfo(message: notifyMessage, avatarPath: msg.avatar!, name: msg.fromUserName!,type: .messge)
                    }else {
                        if UserDataModel.shared.findOneRoomWithIndex(uuid: roomID) != nil {
                            if msg.contentType == ContentType.text.rawValue {
                                let notifyMessage = "\(msg.fromUserName!) : \(msg.content!)"
                                
                                BenHubState.shared.AlertMessageWithUserInfo(message: notifyMessage, avatarPath: GroupRoomAvatar, name: GroupRoomName,type: .messge)
                            }else if msg.contentType == ContentType.msgReply.rawValue {
                                let notifyMessage = "\(msg.fromUserName!) : Reply to a mesasge - \(msg.content!)"
                                
                                BenHubState.shared.AlertMessageWithUserInfo(message: notifyMessage, avatarPath: GroupRoomAvatar, name: GroupRoomName,type: .messge)
                            }else if msg.contentType != ContentType.sys.rawValue{
                                let notifyMessage = "\(msg.fromUserName!) : \(notificationConentMessage(fromUUID: msg.fromUserName!, contentType: msg.contentType!))"
                                
                                BenHubState.shared.AlertMessageWithUserInfo(message: notifyMessage, avatarPath: GroupRoomAvatar, name: GroupRoomName,type: .messge)
                            }
                        }
                    }
                    
                }
            }
            
        }
    }

    
    @MainActor
    func updateMessageStatus(messsageID : String){
        guard let message = UserDataModel.shared.findOneMessage(id: UUID(uuidString: messsageID)!) else {
            print("\(messsageID) : message not found")
            return
        }

        
        UserDataModel.shared.updateMessageStatus(msg: message, status: .ack)
        UserDataModel.shared.fetchUserRoom()
    }
    
    @MainActor
    private func sendAck(messageID : String,formUUID : String) {
        print("send ack to server for messageID : \(messageID)")
        let msg = WSMessage(messageID: messageID, avatar: nil, fromUserName: nil, fromUUID: formUUID, toUUID: nil, content: nil, contentType: nil, type: 6, messageType: nil,urlPath: nil,fileName: nil,fileSize: nil, storyAvailableTime: nil,replyMessageID: nil, storyId: nil)
        onSend(msg: msg)
    }
    
    
    func sendRTCSignal(toUUID : String, sdp : String) {
        print("send signaling")
        let wsMSG = WSMessage(messageID: UUID().uuidString, avatar: userModel?.profile?.avatar, fromUserName: userModel?.profile?.name, fromUUID: userModel?.profile?.uuid, toUUID: toUUID, content:sdp , contentType: 7, type: 5, messageType: 1, urlPath: nil, fileName: nil, fileSize: nil, storyAvailableTime: nil,replyMessageID: nil, storyId: nil)
        
        self.onSend(msg: wsMSG)
    }
    
    func recallMessage(message : RoomMessages,toUUID : String,messageType : Int16,sendMessage : String){
        let recallMessage = WSMessage(messageID: message.id!.uuidString, avatar: message.sender?.avatar, fromUserName: message.sender?.name, fromUUID: message.sender?.id?.uuidString.lowercased(), toUUID: toUUID, content: sendMessage, contentType: ContentType.sys.rawValue, type: 7, messageType: messageType, urlPath: nil, fileName: nil, fileSize: nil, storyAvailableTime: nil, replyMessageID: nil, storyId: nil)
        self.onSend(msg: recallMessage)
    }
    
    @MainActor
    func updateMessage(wsMSG : WSMessage){
        guard let message = UserDataModel.shared.findOneMessage(id: UUID(uuidString: wsMSG.messageID!)!) else {
            return
        }

    
        UserDataModel.shared.deleteMessage(msg: message, content: wsMSG.content ?? "")
        UserDataModel.shared.fetchUserRoom()
    }
}

extension Websocket {
    private func playReceivedMessageSound(){
//        AudioServicesPlaySystemSound(MESSAGE_RECVIVED_SOUND_ID)
        AudioServicesPlayAlertSound(MESSAGE_RECVIVED_SOUND_ID)
            
    }
}


extension Websocket {
    @MainActor
    private func addNewRoomToCache(roomUUID: UUID , msg : WSMessage,roomName : String,roomAvatar : String ,event : MessageEvent,sentTime : Date,messageID : String,storyId : Int16){
        if let room = UserDataModel.shared.addRoom(id: roomUUID.uuidString, name: roomName, avatar: roomAvatar, message_type: msg.messageType!) {
            room.unread_message = event == .send ? 0 : 1
            room.last_message = (msg.contentType == ContentType.text.rawValue || msg.contentType == ContentType.msgReply.rawValue) ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
            room.last_sent_time = sentTime
            
            let RoomMsg = UserDataModel.shared.addRoomMessage(msgID:messageID,sender_uuid: msg.fromUUID!,receiver_uuid:msg.toUUID! ,sender_avatar: msg.avatar ?? "",sender_name: msg.fromUserName ?? "",content: msg.content ?? "",content_type: Int16(msg.contentType!), message_type : msg.messageType!,sent_at:sentTime,fileURL: msg.urlPath ?? "",fileName: msg.fileName ?? "",fileSize: Int64(msg.fileSize ?? 0),storyAvailabeTime: msg.storyAvailableTime ?? 0,event: event,messageStatus: event == .send ? .sending : .received,storyId: storyId)
            
            if msg.contentType == ContentType.msgReply.rawValue{
                if let replyMessage = UserDataModel.shared.findOneMessage(id: UUID(uuidString: msg.replyMessageID!)!) {
                    RoomMsg.replyMessage = replyMessage
                }else {
                    print("Reply Message not found...")
                    return
                }
            }
            room.addToMessages(RoomMsg)
            
            UserDataModel.shared.manager.save()
            UserDataModel.shared.fetchUserRoom()
            print("message saved.")
        }
    }
    
    @MainActor
    private func addNewMessageToRoomCache(msg : WSMessage,room : ActiveRooms,messageID : String,sentTime :Date,event : MessageEvent,storyId : Int16){
        if msg.contentType! != ContentType.sys.rawValue {
            room.last_message = (msg.contentType == ContentType.text.rawValue || msg.contentType == ContentType.msgReply.rawValue) ? msg.content! : fileConentMessage(fromUUID: msg.fromUUID!, contentType: msg.contentType!)
            room.last_sent_time = sentTime
        }
        
        let roomMsg = UserDataModel.shared.addRoomMessage(room: room, msgID:messageID, sender_uuid: msg.fromUUID!,receiver_uuid: msg.toUUID!, sender_avatar: msg.avatar ?? "",sender_name: msg.fromUserName ?? "",content: msg.content ?? "",content_type: Int16(msg.contentType!), message_type: msg.messageType!,sent_at:sentTime,fileURL: msg.urlPath ?? "",fileName: msg.fileName ?? "",fileSize: Int64(msg.fileSize ?? 0),storyAvailabeTime: msg.storyAvailableTime ?? 0,event: event,messageStatus: event == .send ? .sending : .received,storyId: storyId)
        //                print(msg.sender)
        
        //find the replyMessage
        if msg.contentType == ContentType.msgReply.rawValue{
            print(msg)
            if let replyMessage = UserDataModel.shared.findOneMessage(id: UUID(uuidString: msg.replyMessageID!)!) {
                roomMsg.replyMessage = replyMessage
            }else {
                print("Reply Message not found...")
                return
            }
        }
        
        if UserDataModel.shared.currentRoom != nil {
            //inside the room
            UserDataModel.shared.currentRoomMessage.append(roomMsg)
        }else {
            room.unread_message += event == .send ? 0 : 1
        }
        
        UserDataModel.shared.manager.save()
        UserDataModel.shared.fetchUserRoom()
    }
    
}

extension Websocket {
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
        } else if contentType ==  ContentType.sticker.rawValue{
            return self.userModel!.profile!.uuid == fromUUID ? "Sent a sticker" : "Received a sticker."
        } else if contentType == ContentType.sys.rawValue {
            return ""
        } else {
            return ""
        }
    }
    
    @MainActor
    private func notificationConentMessage(fromUUID : String,contentType : Int16) -> String {
        if contentType ==  ContentType.img.rawValue{
            return self.userModel!.profile!.uuid != fromUUID ? "Sent a image." : "Received a image."
        }else if contentType ==  ContentType.file.rawValue {
            return self.userModel!.profile!.uuid != fromUUID ? "Sent a file." : "Received a file."
        }else if contentType ==  ContentType.audio.rawValue {
            return self.userModel!.profile!.uuid != fromUUID ? "Sent a audio" : "Received a audio."
        }else if contentType ==  ContentType.video.rawValue {
            return self.userModel!.profile!.uuid != fromUUID ? "Sent a video" : "Received a video."
        }else if contentType ==  ContentType.story.rawValue{
            return "Reply to a story"
        } else if contentType ==  ContentType.sticker.rawValue {
            return self.userModel!.profile!.uuid != fromUUID ? "Sent a sticker" : "Received a sticker."
        } else if contentType == ContentType.sys.rawValue {
            return ""
        } else {
            return ""
        }
    }
}
