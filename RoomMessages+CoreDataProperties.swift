//
//  RoomMessages+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by TOK MAN MOK on 7/3/2024.
//
//

import Foundation
import CoreData


extension RoomMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomMessages> {
        return NSFetchRequest<RoomMessages>(entityName: "RoomMessages")
    }

    @NSManaged public var content: String?
    @NSManaged public var content_available_time: Int32
    @NSManaged public var content_type: String?
    @NSManaged public var content_user_avatar: String?
    @NSManaged public var content_user_name: String?
    @NSManaged public var content_user_uuid: String?
    @NSManaged public var content_uuid: String?
    @NSManaged public var deleted_at: Date?
    @NSManaged public var file_name: String?
    @NSManaged public var file_size: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var message_status: Int16
    @NSManaged public var sent_at: Date?
    @NSManaged public var tempData: Data?
    @NSManaged public var url_path: String?
    @NSManaged public var replyMessage: RoomMessages?
    @NSManaged public var room: ActiveRooms?
    @NSManaged public var sender: SenderInfo?

}

extension RoomMessages : Identifiable {
    var FileURL : URL{
        let url = self.url_path!
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters:.urlPathAllowed) ?? ""
        return URL(string: RESOURCES_HOST+encodedURL)!
    }
    
    var StickerURL : URL{
        let url = self.url_path!
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters:.urlPathAllowed) ?? ""
        return URL(string: RESOURCES_HOST+"/sticker"+encodedURL)!
    }
    
    var FileSizeInMB : Double {
        if self.file_size == 0 {
            return 0
        }
        return Double(self.file_size) / 1048576 //byte -> MB
    }
   
    var isStoryAvailable : Bool{
        let distance = Date.now.distance(to: Date(timeIntervalSince1970: TimeInterval(self.content_available_time)))
        return abs(distance) <= 86400
    }
    
    var StoryUserAvatarURL : URL {
        return URL(string: RESOURCES_HOST  + (self.content_user_avatar ?? ""))!
    }

    var messageStatus : MessageStatus {
        switch self.message_status {
        case 1: return .sending
        case 2: return .ack
        case 3: return .received
        case 4: return .notAck
        default: return .unknow
        }
    }
    
    var replyMessageContent : String {
        guard let replyMsg = self.replyMessage else {
            return ""
        }
        if self.content_type == ContentType.REPLY.rawValue {
            var message : String = ""
            
            switch replyMsg.content_type {
            case ContentType.TEXT.rawValue,ContentType.REPLY.rawValue:
                message.append(replyMsg.content ?? "")
                break
            case ContentType.IMAGE.rawValue:
                message.append("[ image content ]")
                break
            case ContentType.FILE.rawValue:
                message.append("[ file content ]")
                break
            case ContentType.AUDIO.rawValue:
                message.append("[ audio content ]")
                break
            case ContentType.VIDEO.rawValue:
                message.append("[ video content ]")
                break
            case ContentType.STORY.rawValue:
                message.append("[ story content ]")
                break
            case ContentType.SHARED.rawValue:
                message.append("[ story share content ]")
                break
            default:
                return ""
                
            }
            
            return message
        }
        return ""
    }
}

extension RoomMessages {
    var messageDeleted : Bool {
        return self.deleted_at == nil ? false : true
    }
}

enum MessageStatus : Int16 {
    case sending
    case ack
    case received
    case notAck
    case unknow
    
    var rawValue: Int16 {
        switch self {
        case .unknow : return 0
        case .sending : return 1
        case .ack : return 2
        case .received : return 3
        case .notAck : return 4
        }
    }
}
