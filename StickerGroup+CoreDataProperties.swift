//
//  StickerGroup+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//
//

import Foundation
import CoreData


extension StickerGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StickerGroup> {
        return NSFetchRequest<StickerGroup>(entityName: "StickerGroup")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var resoucres: NSSet?

}

// MARK: Generated accessors for resoucres
extension StickerGroup {

    @objc(addResoucresObject:)
    @NSManaged public func addToResoucres(_ value: StickerGroupResources)

    @objc(removeResoucresObject:)
    @NSManaged public func removeFromResoucres(_ value: StickerGroupResources)

    @objc(addResoucres:)
    @NSManaged public func addToResoucres(_ values: NSSet)

    @objc(removeResoucres:)
    @NSManaged public func removeFromResoucres(_ values: NSSet)

}

extension StickerGroup : Identifiable {

}
