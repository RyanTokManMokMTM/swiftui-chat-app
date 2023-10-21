//
//  RoomMessages+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/10/2023.
//
//

import Foundation
import CoreData


extension RoomMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomMessages> {
        return NSFetchRequest<RoomMessages>(entityName: "RoomMessages")
    }

    @NSManaged public var content: String?
    @NSManaged public var content_type: Int16
    @NSManaged public var deleted_at: Date?
    @NSManaged public var file_name: String?
    @NSManaged public var file_size: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var message_status: Int16
    @NSManaged public var sent_at: Date?
    @NSManaged public var story_available_time: Int32
    @NSManaged public var story_id: Int16
    @NSManaged public var story_user_avatar: String?
    @NSManaged public var story_user_name: String?
    @NSManaged public var story_user_uuid: String?
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
    
    var FileSizeInMB : Double {
        if self.file_size == 0 {
            return 0
        }
        return Double(self.file_size) / 1048576 //byte -> MB
    }
   
    var isStoryAvailable : Bool{
        let distance = Date.now.distance(to: Date(timeIntervalSince1970: TimeInterval(self.story_available_time)))
        return abs(distance) <= 86400
    }
    
    var StoryUserAvatarURL : URL {
        return URL(string: RESOURCES_HOST  + (self.story_user_avatar ?? ""))!
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
        if self.content_type == ContentType.msgReply.rawValue {
            var message : String = ""
            
            switch replyMsg.content_type {
            case ContentType.text.rawValue,ContentType.msgReply.rawValue:
                message.append(replyMsg.content ?? "")
                break
            case ContentType.img.rawValue:
                message.append("[ image content ]")
                break
            case ContentType.file.rawValue:
                message.append("[ file content ]")
                break
            case ContentType.audio.rawValue:
                message.append("[ audio content ]")
                break
            case ContentType.video.rawValue:
                message.append("[ video content ]")
                break
            case ContentType.story.rawValue:
                message.append("[ story content ]")
                break
            case ContentType.share.rawValue:
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
