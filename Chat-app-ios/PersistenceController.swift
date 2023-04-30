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
//
//    func FetchUserActiveRooms(userID : Int16) {
//        print(userID)
////        let predict = NSPredicate(format: "user_id == %@", "\(userID)")
//        let request = NSFetchRequest<ActiveRooms>(entityName: "ActiveRooms")
////        request.predicate = predict
//
//        do {
//            self.rooms = try self.container.viewContext.fetch(request)
//        } catch(let err) {
//            print("fetch user active error \(err.localizedDescription)")
//        }
//    }
//
//    func CreateUserActiveRoom(id : String,name : String, avatar : String,user_id : Int16,message_type : Int16) -> ActiveRooms? {
//        let activeRoom = ActiveRooms(context: self.container.viewContext)
//        activeRoom.id = UUID(uuidString: id)
//        activeRoom.name = name
//        activeRoom.user_id = user_id
//        activeRoom.avatar = avatar
//        activeRoom.message_type = message_type
//
//        do {
//            try self.container.viewContext.save()
//            DispatchQueue.main.async {
//                self.rooms.append(activeRoom)
//
//            }
//            return activeRoom
//        }catch (let err){
//            print("Save room to core data err \(err.localizedDescription)")
//            return nil
//        }
//    }
//
//    func DeleteUserActiveRoom(){}
//
//    func UpdateUserActiveRoom(){
////        self.container.viewContext.updatedOb
//    }
//
//    func FindOneRoom(uuid : UUID,userID :Int16) -> ActiveRooms? {
//        let predicate1 = NSPredicate(format: "id == %@", uuid as CVarArg)
//        let predicate2 = NSPredicate(format: "user_id == %i", userID)
//
//        let combine = NSCompoundPredicate(type: .and, subpredicates: [predicate1,predicate2])
//        let req = NSFetchRequest<ActiveRooms>(entityName: "ActiveRooms")
//        req.predicate = combine
//        req.fetchLimit = 1
//
//        do {
//            let result = try container.viewContext.fetch(req)
//            if result.isEmpty {
//                return nil
//            }
//            return result.first
//        } catch (let err){
//            print(err.localizedDescription)
//            return nil
//        }
//    }
//
//
    func save(){
        do{
            try context.save()
        } catch let err {
            print("save err\(err.localizedDescription)")
        }
    }
    
}
