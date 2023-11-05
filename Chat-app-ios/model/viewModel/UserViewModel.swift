//
//  UserViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/3/2023.
//

import Foundation


class UserViewModel : ObservableObject {
    @Published var profile : UserProfile?
    @Published var friendsList : [UserProfile] = [UserProfile]()
    @Published var userStickerList : [StickerInfo] = [StickerInfo]()
    @Published var userStickerIndex = 0
    
    func reset(){
        self.profile = nil
        self.friendsList = []
        self.userStickerList = []
    }
    
    func GetUserFriendList() async{
        DispatchQueue.main.async {
            BenHubState.shared.SetWait(message: "Loading...")
        }
        let resp = await ChatAppService.shared.GetFriendList()
        DispatchQueue.main.async {
            switch resp{
            case .success(let data):
                BenHubState.shared.isWaiting = false
                self.friendsList = data.friends
                
            case .failure(let err):
                
                BenHubState.shared.isWaiting = false
                BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            }
        }
    }
    func GetUserUserStickerList() async{
        let resp = await ChatAppService.shared.GetUserStickerList()
        DispatchQueue.main.async {
            switch resp{
            case .success(let data):
                if !data.stickers.isEmpty {
                    self.userStickerList = data.stickers
                    self.userStickerIndex = min( self.userStickerIndex, data.stickers.count - 1)
                }
                
                
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    

}

struct UserProfile : Identifiable ,Decodable {
    let id : UInt
    let uuid : String
    var name : String
    let email : String
    var avatar : String
    var cover : String
    var status : String
    
    var UserUUID : UUID {
        return UUID(uuidString: self.uuid)!
    }
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST  + self.avatar)!
    }
    
    var CoverURL : URL {
        return URL(string: RESOURCES_HOST  + self.cover)!
    }
}
