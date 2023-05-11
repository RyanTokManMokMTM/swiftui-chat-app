//
//  BenHubState.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI
import Foundation

enum StateType {
    case normal
    case messge
    case system
}

struct Info  {
    let avatarPath : String
    let name : String
    
    
    var AvatarURL : URL {
        return URL(string: RESOURCES_HOST + self.avatarPath)!
    }
}

final class BenHubState : ObservableObject {
    @Published var isWaiting : Bool = false
    @Published var isPresented : Bool = false
    
    private(set) var message : String = ""
    private(set) var sysImg : String = ""
    private(set) var info : Info? = nil
    private(set) var type : StateType = .normal
    
    static let shared = BenHubState()
    
    private init(){}
    
    func SetWait(message : String) {
        self.message = message
        withAnimation{
            self.isWaiting = true
        }
    }
    
    func AlertMessageWithUserInfo(message : String, avatarPath : String , name : String ,type : StateType = .normal){
        self.message = message
        self.info = Info(avatarPath: avatarPath, name: name)
        self.type = type
        
        DispatchQueue.main.async {
            withAnimation{
                self.isPresented = true
            }
        }
        
    }
    
    func AlertMessage(sysImg : String, message : String) {
        self.sysImg = sysImg
        self.message = message
        
        DispatchQueue.main.async {
            withAnimation{
                self.isPresented = true
            }
        }
    }
}
