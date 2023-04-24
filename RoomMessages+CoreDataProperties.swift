//
//  RoomMessages+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 24/4/2023.
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
    @NSManaged public var file_name: String?
    @NSManaged public var file_size: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var sent_at: Date?
    @NSManaged public var story_available_time: Int32
    @NSManaged public var tempData: Data?
    @NSManaged public var url_path: String?
    @NSManaged public var room: ActiveRooms?
    @NSManaged public var sender: SenderInfo?

}

extension RoomMessages : Identifiable {
//    var AvatarURL : URL {
//         return URL(string: RESOURCES_HOST + self.sender_avatar!)!
//     }
     
     var FileURL : URL{
         return URL(string: RESOURCES_HOST + self.url_path!)!
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
}
