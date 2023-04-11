//
//  ActiveRooms+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 9/4/2023.
//
//

import Foundation
import CoreData


extension ActiveRooms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveRooms> {
        return NSFetchRequest<ActiveRooms>(entityName: "ActiveRooms")
    }

    @NSManaged public var avatar: String?
    @NSManaged public var id: UUID?
    @NSManaged public var last_message: String?
    @NSManaged public var last_sent_time: Date?
    @NSManaged public var message_type: Int16
    @NSManaged public var name: String?
    @NSManaged public var unread_message: Int16
    @NSManaged public var messages: NSSet?
    @NSManaged public var user: UserDatas?

}

// MARK: Generated accessors for messages
extension ActiveRooms {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: RoomMessages)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: RoomMessages)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

extension ActiveRooms : Identifiable {
    var AvatarURL : URL {
        URL(string: RESOURCES_HOST + self.avatar!)!
    }
    
    var IsUnreal : Bool {
        return self.unread_message > 0
    }

}
