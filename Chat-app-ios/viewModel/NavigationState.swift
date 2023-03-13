//
//  NavigationState.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 13/3/2023.
//

import Foundation

class NavigationState : ObservableObject {
    static let shared = NavigationState()
    private init(){}
    
    @Published var navigationRoomPath : [ActiveRooms] = []
}
