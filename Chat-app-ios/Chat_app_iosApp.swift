//
//  Chat_app_iosApp.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import SwiftUI
import AVKit
class SoundManager : ObservableObject {
    static let shared = SoundManager()
    var player : AVAudioPlayer?
    
    func playSound(url : URL, repeatTime : Int = 50){
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = repeatTime
            player?.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    func stopPlaying(){
        player?.stop()
        player = nil
    }
}
@main
struct Chat_app_iosApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceContainer = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
//            AudioPlayerView( fileName: "test.mp3", path: "/test.mp3")
            ContentView()
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
        }
    }
}
