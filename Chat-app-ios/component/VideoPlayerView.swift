//
//  VideoPlayerView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 29/4/2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Binding var isShowVideoPlayer : Bool
    @State private var avPlayer : AVPlayer? = nil
    let url : URL
    var body: some View {
        VideoPlayer(player: avPlayer)
            .frame(width:UIScreen.main.bounds.width)
            .onAppear(){
                self.avPlayer = AVPlayer(url: url)
                self.avPlayer?.play()
            }
            .background(Color.black)
            .overlay(alignment:.topLeading){
                Button(action:{
                    withAnimation{
                        self.isShowVideoPlayer = false
                    }
                }){
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(BlurView().cornerRadius(25))
                }
                .padding()
            }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(isShowVideoPlayer: .constant(true), url: URL(string: RESOURCES_HOST + "/4BF03C75-9120-4405-B34B-12D033559292.mp4")!)
    }
}
