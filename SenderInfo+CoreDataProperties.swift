//
//  SenderInfo+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 24/4/2023.
//
//

import Foundation
import CoreData


extension SenderInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SenderInfo> {
        return NSFetchRequest<SenderInfo>(entityName: "SenderInfo")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var avatar: String?
    @NSManaged public var name: String?
    @NSManaged public var roomMessage: NSSet?

}

// MARK: Generated accessors for roomMessage
extension SenderInfo {

    @objc(addRoomMessageObject:)
    @NSManaged public func addToRoomMessage(_ value: RoomMessages)

    @objc(removeRoomMessageObject:)
    @NSManaged public func removeFromRoomMessage(_ value: RoomMessages)

    @objc(addRoomMessage:)
    @NSManaged public func addToRoomMessage(_ values: NSSet)

    @objc(removeRoomMessage:)
    @NSManaged public func removeFromRoomMessage(_ values: NSSet)

}

extension SenderInfo : Identifiable {
    var AvatarURL : URL {
         return URL(string: RESOURCES_HOST + self.avatar!)!
     }
}
