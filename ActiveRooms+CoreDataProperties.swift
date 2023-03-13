//
//  ActiveRooms+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 13/3/2023.
//
//

import Foundation
import CoreData


extension ActiveRooms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveRooms> {
        return NSFetchRequest<ActiveRooms>(entityName: "ActiveRooms")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var avatar: String?
    @NSManaged public var message_type: Int16
    @NSManaged public var last_sent_time: Date?
    @NSManaged public var last_message: String?
    @NSManaged public var user_id: Int16
    @NSManaged public var unread_message: Int16

}

extension ActiveRooms : Identifiable {
    var AvatarURL : URL {
        URL(string: RESOURCES_HOST + self.avatar!)!
    }
    
    var IsUnreal : Bool {
        return self.unread_message > 0
    }
}
