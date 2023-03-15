//
//  Websocket.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/3/2023.
//

import Foundation
import Combine


struct WSMessage : Codable {
    let avatar : String?
    let fromUserName : String?
    let fromUUID : String?
    let toUUID : String?
    let content : String?
    let contentType : Int32?
    let type : Int32?
    let messageType : Int32?

}


final class Webcoket {
    let WS_HOST = "ws://127.0.0.1:8000/ws"
    var session : URLSessionWebSocketTask?
    static var shared = Webcoket()
    
    private var anyCancellable : AnyCancellable? = nil
//    var userData : UserDataModel? {
//        didSet {
//            print("???")
//            self.userData?.objectWillChange.send()
//            anyCancellable = userData?.objectWillChange.sink(receiveValue: { _ in
//                self.userData?.objectWillChange.send()
//            })
//        }
//    }
    
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
                do {
                    let msg = try JSONDecoder().decode(WSMessage.self, from: data)
//                    print(msg)
                    
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
                            DispatchQueue.main.async {
                                if let index = UserDataModel.shared.findOneRoomWithIndex(uuid: UUID(uuidString: msg.fromUUID!)!){
                                    print("testing")
                                    let sentTime = Date.now
                                    UserDataModel.shared.rooms[index].unread_message += 1
                                    UserDataModel.shared.rooms[index].last_message = msg.content!
                                    UserDataModel.shared.rooms[index].last_sent_time = sentTime
                                    
                                   let msg = UserDataModel.shared.addRoomMessage(roomIndex: index, sender_uuid: msg.fromUUID!, sender_avatar: msg.avatar!, content: msg.content!, content_type: Int16(msg.contentType!), sent_at:sentTime)
                                    
                                    if UserDataModel.shared.currentRoom == index {
                                        UserDataModel.shared.currentRoomMessage.append(msg)
                                    }
                                    UserDataModel.shared.manager.save()
                                    UserDataModel.shared.fetchUserRoom()
                                }
                            }
                            
                           
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
        let msg = WSMessage(avatar: nil, fromUserName: nil, fromUUID: nil, toUUID: nil, content: "pong", contentType: nil, type: 2, messageType: nil)
        onSend(msg: msg)
    }
}
