//
//  UserDatas+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 14/3/2023.
//
//

import Foundation
import CoreData


extension UserDatas {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDatas> {
        return NSFetchRequest<UserDatas>(entityName: "UserDatas")
    }

    @NSManaged public var id: Int16
    @NSManaged public var uuid: UUID?
    @NSManaged public var name: String?
    @NSManaged public var avatar: String?
    @NSManaged public var email: String?
    @NSManaged public var rooms: NSSet?

}

// MARK: Generated accessors for rooms
extension UserDatas {

    @objc(addRoomsObject:)
    @NSManaged public func addToRooms(_ value: ActiveRooms)

    @objc(removeRoomsObject:)
    @NSManaged public func removeFromRooms(_ value: ActiveRooms)

    @objc(addRooms:)
    @NSManaged public func addToRooms(_ values: NSSet)

    @objc(removeRooms:)
    @NSManaged public func removeFromRooms(_ values: NSSet)

}

extension UserDatas : Identifiable {

}
