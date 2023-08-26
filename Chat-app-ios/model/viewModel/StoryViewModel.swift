//
//  StoryViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

class StoryViewModel : ObservableObject {
    
    @Published var activeStories : [FriendStory] = []
    @Published var isShowStory : Bool = false
    @Published var currentStory : UInt = 0
    
    func reset(){
        self.activeStories = []
        self.isShowStory = false
        self.currentStory = 0
    }
    
    func GetActiveStory() async {
        let resp = await ChatAppService.shared.GetActiveStories()
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
//                print(data.active_stories)
                withAnimation{
                    self.activeStories = data.active_stories
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
}


class UserStoryViewModel : ObservableObject {
    @Published var userStories : [UInt] = []
    @Published var isShowStory : Bool = false
    @Published var isSeen : Bool = false
    @Published var currentStoryIndex = 0
    @Published var currentStoryID : UInt = 0
    
    func reset(){
        self.userStories = []
        self.isShowStory = false
        self.isSeen = false
        self.currentStoryID = 0
        self.currentStoryIndex = 0
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
