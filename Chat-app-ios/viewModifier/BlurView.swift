//
//  BlurView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 17/2/2023.
//

import SwiftUI
import UIKit

struct BlurView : UIViewRepresentable {
    var style : UIBlurEffect.Style = .systemMaterialDark
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
}

