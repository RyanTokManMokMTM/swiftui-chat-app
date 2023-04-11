//
//  StoryViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/4/2023.
//

import SwiftUI

class StoryViewModel : ObservableObject {
    @Published var stories : [StoryBuddle] = [
        StoryBuddle(profileName: "Olivia", profileAvatar: "/default2.jpg", isSeen: false, stories: [
            Story(imageURL: "story12",create_time: 1681089136),
            Story(imageURL: "story13",create_time: 1681092736),
            Story(imageURL: "story16",create_time: 1681093816),
            Story(imageURL: "story4",create_time: 1681095676),
            Story(imageURL: "story5",create_time: 1681106476),
            Story(imageURL: "story6",create_time: 1681124476),
            Story(imageURL: "story7",create_time: 1681132816),
            Story(imageURL: "story8",create_time: 1681136416),
            Story(imageURL: "story9",create_time: 1681137742),
        ]),
        StoryBuddle(profileName: "Alice", profileAvatar: "/default3.jpg", isSeen: false, stories: [
            Story(imageURL: "story11",create_time: 1681092736),
            Story(imageURL: "story17",create_time: 1681093816),
            Story(imageURL: "story14",create_time: 1681124476),
            Story(imageURL: "story15",create_time: 1681136416)
        ]),
        StoryBuddle(profileName: "Ryan", profileAvatar: "/default4.jpg", isSeen: false, stories: [
            Story(imageURL: "story1",create_time: 1681092736),
            Story(imageURL: "story2",create_time: 1681106476)
        ]),

    ]
    
    @Published var isShowStory : Bool = false
    @Published var currentStory : String = "" // index to story
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
