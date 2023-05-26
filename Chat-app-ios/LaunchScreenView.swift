//
//  LaunchScreenView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 25/5/2023.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimiate : Bool = false
    var body: some View {
        VStack {
            Image(systemName: "message.fill")
                .imageScale(.large)
                .foregroundColor(.white)
                .scaleEffect(3)
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(Color.green.edgesIgnoringSafeArea(.all))
        
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
