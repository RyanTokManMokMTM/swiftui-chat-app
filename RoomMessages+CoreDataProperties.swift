//
//  RoomMessages+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/3/2023.
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
    @NSManaged public var id: UUID?
    @NSManaged public var sender_avatar: String?
    @NSManaged public var sender_uuid: UUID?
    @NSManaged public var sent_at: Date?
    @NSManaged public var room: ActiveRooms?

}

extension RoomMessages : Identifiable {
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.sender_avatar!)!
    }
}
