//
//  AudioPlayerView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 28/4/2023.
//

import SwiftUI
import AVKit
struct AudioPlayerView: View {
    @State var audioPlayer: AVPlayer = AVPlayer()
    @State private var isPlaying : Bool = false
    @State private var value : Double = 0.0
    @State private var isEditing : Bool = false
    @Binding var isPlayingAudio : Bool
    let fileName : String
    let path : URL

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack{
            Spacer()
            Image(systemName: "music.quarternote.3")
                .imageScale(.large)
                .scaleEffect(2)
            Spacer()
            
            
            
            Text(fileName)
                .font(.title3)
                .padding()
                .multilineTextAlignment(.leading)
                .padding(.vertical)

            HStack {
                Text("\(DateComponentsFormatter.positional.string(from: value) ?? "0:00")")
                    .frame(width: 40)
                    .font(.system(size: 14))
                
//
                
                Slider(value: $value, in:0...Double((self.audioPlayer.currentItem?.asset.duration.seconds ?? 0))){ edit in
                    withAnimation {
                        self.isEditing = edit
                    }
                    
                    if !self.isEditing {
                        audioPlayer.seek(to: CMTimeMakeWithSeconds(value, preferredTimescale: 1000))
                    }
                }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    
                
                Text("\(DateComponentsFormatter.positional.string(from: self.audioPlayer.currentItem?.asset.duration.seconds ?? 0) ?? "0:00")")
                    .frame(width: 40)
                    .font(.system(size: 14))
            }
            .padding()
            
            
            Button(action: {
                if isPlaying {
                    self.audioPlayer.pause()
                }else {
                    self.audioPlayer.play()
                    
                }
                withAnimation{
                    self.isPlaying.toggle()
                }
                
            }){
                Image(systemName: self.isPlaying ? "pause.circle.fill" : "play.circle.fill").resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            }
      
        }
        .overlay(alignment:.topLeading){
            Button(action: {
                withAnimation{
                    self.isPlayingAudio = false
                }
            }){
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .foregroundColor(.black)
            }
            .padding()
            
        }
        .onReceive(timer){ _ in
            if !isEditing {
                self.value = audioPlayer.currentTime().seconds
            }
           
            if let asset = audioPlayer.currentItem {
                if asset.duration.seconds.isNaN {
                    return
                }
                if self.isPlaying && Int(self.value) >= Int(asset.duration.seconds) {
                    withAnimation{
                        self.isPlaying = false
                        audioPlayer.seek(to: .zero)
                    }
                }
            }
            
        
        }
        .padding(.bottom)
        .onAppear{
            print(self.path.absoluteURL)
            self.audioPlayer.replaceCurrentItem(with: .init(url: self.path))
            play()
        }
        .onDisappear{
            pause()
        }
    }
    
    @MainActor
    private func play(){
        if self.audioPlayer.currentItem != nil {
            withAnimation{
                self.audioPlayer.play()
                self.isPlaying = true
            }
        }
    }
    
    private func pause(){
        if self.audioPlayer.currentItem != nil {
            withAnimation{
                self.audioPlayer.pause()
                self.isPlaying = false
            }
        }
    }
}
//
//struct AudioPlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioPlayerView( path: "/sample-3s.mp3")
//    }
//}
