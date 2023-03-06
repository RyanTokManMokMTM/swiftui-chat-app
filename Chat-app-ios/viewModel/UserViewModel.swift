//
//  UserViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import Foundation
class UserViewModel : ObservableObject {
    @Published var profile : UserProfile?
}

struct UserProfile : Identifiable ,Decodable {
    let id : UInt
    let uuid : String
    let name : String
    let email : String
    let avatar : String
    
    var UserUUID : UUID {
        return UUID(uuidString: self.uuid)!
    }
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST  + self.avatar)!
    }
}
