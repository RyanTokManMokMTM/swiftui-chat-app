//
//  StoryViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI
struct ShareUserProfile  {
    let profile : UserProfile
    var isSelected : Bool = false
}

class StoryViewModel : ObservableObject {
    
    @Published var activeStories : [FriendStory] = []
    @Published var isShowStory : Bool = false
    @Published var currentStory : UInt = 0
    
    @Published var friendsList : [ShareUserProfile] = [ShareUserProfile]()
    @Published var isLoading = false
    func reset(){
        self.activeStories = []
        self.friendsList = []
        self.isShowStory = false
        self.currentStory = 0
    }
    
    func GetActiveStory() async {
        let resp = await ChatAppService.shared.GetActiveStories()
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                withAnimation{
                    self.activeStories = data.active_stories.sorted(by: { !$0.is_seen && $1.is_seen})
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    

    func GetUserFriendList() async{
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let resp = await ChatAppService.shared.GetFriendList()
        DispatchQueue.main.async {
            self.isLoading = false
            switch resp{
            case .success(let data):
                BenHubState.shared.isWaiting = false
                self.friendsList = data.friends.map{ info in
                    ShareUserProfile(profile: info)
                }
                
            case .failure(let err):
                
                BenHubState.shared.isWaiting = false
                BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            }
        }
    }
    
    func GetSearchResult(keyword : String) async{
        if keyword.isEmpty{
            Task{
                await GetUserFriendList()
            }
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let resp = await ChatAppService.shared.SearchUser(email: keyword)
        DispatchQueue.main.async {
            self.isLoading = false
            switch resp {
            case .success(let data):
                if data.code == 200 {
                    DispatchQueue.main.async {
                        self.friendsList = data.results?.map{ info in
                                  ShareUserProfile(profile: info.user_info)
                            
                        } ?? []
                    }

                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }

        
//        ChatAppService.shared
    }
    

  
}


class UserStoryViewModel : ObservableObject {
    @Published var userStories : [UInt] = []
    @Published var isShowStory : Bool = false
    @Published var isSeen : Bool = false
    @Published var currentStoryIndex = 0
    @Published var currentStoryID : UInt = 0
    @Published var currentStorySeen : UInt = 0
    @Published var storySeenList : [StorySeenInfo] = [StorySeenInfo]()
    @Published var isLoading = false
    
    func reset(){
        self.userStories = []
        self.isShowStory = false
        self.isSeen = false
        self.currentStoryID = 0
        self.currentStoryIndex = 0
        self.currentStorySeen = 0
        self.storySeenList = []
    }
    
    func GetUserStories(userId : Int) async{
        let resp = await ChatAppService.shared.GetUserStories(id: userId)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                self.userStories = data.story_ids
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    func hasStories() -> Bool{
        return !self.userStories.isEmpty
    }
    
    @MainActor
    func deleteStory(storyID : UInt) async -> Bool {
        //Find the story with Its id in userStories
        let index = self.userStories.firstIndex(where: {$0 == storyID}) ?? -1
        if index == -1 {
            return false
        }
        let req = DeleteStoryReq(story_id: storyID)
        let resp = await ChatAppService.shared.DeleteStory(req: req)
        
        switch resp {
        case .success(_):
//            print(data)
            //MARK: Remove the story from activeStories as well,but it need to be check for out-range error
//            BenHubState.shared.AlertMessage(sysImg: "check", message: "Deleted")
            self.userStories.remove(at: index)
            
            if self.userStories.isEmpty {
                withAnimation{
                    self.isShowStory = false
                }
                return true
            }
            
            
            self.currentStoryIndex = min(self.currentStoryIndex,self.userStories.count - 1)
            self.currentStoryID = self.userStories[self.currentStoryIndex]
           
            return true
        case .failure(let err):
            print(err.localizedDescription)
            return false
        }
    }
    
    func GetStorySeenList(storyID : UInt) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let resp = await ChatAppService.shared.GetStorySeenList(storyId: storyID)
        DispatchQueue.main.async {
            self.isLoading = false
            
            switch resp {
            case .success(let data):
                self.storySeenList = data.seen_list.sorted(by: {  $0.is_liked && !$1.is_liked})
                self.currentStorySeen = data.total_seen
            
            case .failure(let err):
                print(err.localizedDescription)
                
            }
        }
    }
    
}
 
struct ActiveStoryUser : Identifiable {
    let id : UInt
    let name : String
    let avatar : String
    var isSeen : Bool
    var stories : [UInt]
    
    var profileAvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatar)!
    }
}

struct StoryBuddle : Identifiable {
    let id = UUID().uuidString
    let profileName : String
    let profileAvatar : String
    var isSeen : Bool
    var stories : [Story]
    var profileAvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.profileAvatar)!
    }

}

struct Story : Identifiable {
    let id = UUID().uuidString
    let imageURL : String
    var create_time : Int
    
    var createTime : Date {
        return Date(timeIntervalSince1970: TimeInterval(self.create_time))
    }
}
