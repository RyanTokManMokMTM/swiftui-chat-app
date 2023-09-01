//
//  DragTextView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 27/5/2023.
//

import SwiftUI
struct TextBox : Identifiable {
    var id = UUID().uuidString
    var text : String = ""
    var isBold : Bool = false
    
    var offset : CGSize = .zero
    var lastOffset : CGSize = .zero
    //other...
    
    var textColor : Color = .white
    var isBorder : Bool = false
    var order : Double = 1
}
