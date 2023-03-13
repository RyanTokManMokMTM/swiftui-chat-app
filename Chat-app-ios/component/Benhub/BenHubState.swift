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
}

final class BenHubState : ObservableObject {
    @Published var isWaiting : Bool = false
    @Published var isPresented : Bool = false
    
    private(set) var message : String = ""
    private(set) var sysImg : String = ""
    
    static let shared = BenHubState()
    
    private init(){}
    
    func SetWait(message : String) {
        self.message = message
        withAnimation{
            self.isWaiting = true
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
