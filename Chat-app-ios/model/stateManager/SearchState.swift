//
//  SearchState.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/7/2023.
//

import Foundation

class SearchState : ObservableObject {
    @Published var isChatFromProfile : Bool = false
    @Published var chatUser : UserProfile? = nil

    func reset(){
        self.isChatFromProfile = false
        self.chatUser = nil
    }
}
