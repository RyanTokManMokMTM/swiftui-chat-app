//
//  GroupViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/3/2023.
//

import Foundation

class GroupViewModel : ObservableObject {
    @Published var members : [UserProfile] = []
    init(){}
    
    
    func UpdateGroupMember(info : UserProfile) {
        if let index = self.members.firstIndex(where: {$0.id == info.id}) {
            //exist -> remove
            self.members.remove(at: index)
        }else {
            self.members.append(info)
        }
    }
    
    func DeleteSelectedMember(info : UserProfile) {
        if let index = self.members.firstIndex(where: {$0.id == info.id}) {
            //exist -> remove
            self.members.remove(at: index)
            
        }
    }
    

}
