//
//  Chat_app_iosApp.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import SwiftUI
import AVKit

@main
struct Chat_app_iosApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isEnd = false
    let persistenceContainer = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                    .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
            }
                
        }
    }
}
