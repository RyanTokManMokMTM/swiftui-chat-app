//
//  RTCVideoView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 8/5/2023.
//

import Foundation
import WebRTC
import SwiftUI

struct RTCVideoView : UIViewRepresentable {
    let track : RTCVideoTrack?
    let webClient : WebRTCClient?
    let isRemote : Bool
    let isVoice : Bool
    @Binding var refershTrack : Bool
    func makeUIView(context: Context) -> RTCMTLVideoView {
        let view = RTCMTLVideoView(frame: .zero)
        if isVoice {
            return view
        }
        
        view.videoContentMode = .scaleAspectFill
        if isRemote {
            self.webClient?.renderRemoteVideo(renderer: view)
        }else {
            self.webClient?.startCapture(renderer: view)
        }

        return view
    }
    
    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
        if refershTrack {
            if isVoice {
                DispatchQueue.main.async {
                    refershTrack = false
                }

                return
            }
            
            DispatchQueue.main.async {
                if isRemote {
                    self.webClient?.renderRemoteVideo(renderer: uiView)
                }else {
                    self.webClient?.startCapture(renderer: uiView)
                }
                refershTrack = false
            }
            
        }
    }
}
