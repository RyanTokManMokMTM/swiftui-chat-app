//
//  StickerGroupResources+CoreDataProperties.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//
//

import Foundation
import CoreData


extension StickerGroupResources {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StickerGroupResources> {
        return NSFetchRequest<StickerGroupResources>(entityName: "StickerGroupResources")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var path: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var relationship: StickerGroup?

}

extension StickerGroupResources : Identifiable {

}
