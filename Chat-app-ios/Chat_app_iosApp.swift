//
//  Chat_app_iosApp.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 15/2/2023.
//

import SwiftUI

@main
struct Chat_app_iosApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceContainer = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
//            ContentView2()
//            ContentView3()
           
        }
    }
}


struct ContentView2: View {
    @State private var isShowingDetailView = false

    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: Text("Second View"), isActive: $isShowingDetailView) { EmptyView() }

                Button("Tap to show detail") {
                    isShowingDetailView = true
                }
            }
            .navigationTitle("Navigation")
        }
    }
}
struct ContentView3: View {
    @State private var presentedNumbers = [1]

    var body: some View {
        NavigationStack(path: $presentedNumbers) {
            List(1..<50) { i in
                NavigationLink(value: i) {
                    Label("Row \(i)", systemImage: "\(i).circle")
                }
            }
            .navigationDestination(for: Int.self) { i in
                Text("Detail \(i)")
            }
            .navigationTitle("Navigation")
        }
    }
}
