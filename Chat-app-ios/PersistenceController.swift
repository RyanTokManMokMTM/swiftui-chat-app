//
//  PersistenceController.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 11/3/2023.
//

import Foundation
import CoreData

class PersistenceController : ObservableObject{
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    let context :  NSManagedObjectContext
    
//    @Published var rooms : [ActiveRooms] = []
    private init() {
        container = NSPersistentContainer(name: "Model")
        print(NSPersistentContainer.defaultDirectoryURL())
        container.loadPersistentStores{ (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolve Error: \(error)")
            }
        }
        
        self.context = container.viewContext
        self.context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }

    func save(){
        do{
            try context.save()
        } catch let err {
            print("save err\(err.localizedDescription)")
        }
    }
    
}
