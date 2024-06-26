//
//  BenHubState.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI
import Foundation
import Combine


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
    
    private var cancelable : Set<AnyCancellable> = []
    private(set) var message : String = ""
    private(set) var sysImg : String = ""
    private(set) var info : Info? = nil
    private(set) var type : StateType = .normal

    
    static let shared = BenHubState()
    
    private init(){
        self.persentedPublishr
            .sink{ persent in
                if persent == true{
                    withAnimation{
                        self.isPresented = false
                    }
                }
                
            }
            .store(in: &cancelable)
    }
    
    func reset() {
        self.message.removeAll()
        self.sysImg.removeAll()
        self.info = nil
        self.type = .normal
    }
    
    func SetWait(message : String) {
        reset()
        self.message = message
        withAnimation{
            self.isWaiting = true
        }
    }
    

    
    func AlertMessageWithUserInfo(message : String, avatarPath : String , name : String ,type : StateType = .normal){
        reset()
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
        reset()
        self.sysImg = sysImg
        self.message = message
        
        DispatchQueue.main.async {
            withAnimation{
                self.isPresented = true
            }
        }
    }
    
    private var persentedPublishr : AnyPublisher<Bool,Never>{
        $isPresented
            .debounce(for: 2, scheduler: RunLoop.main)
            .map{ _isPresented in
                return _isPresented
            }
            .eraseToAnyPublisher()
    }
}
