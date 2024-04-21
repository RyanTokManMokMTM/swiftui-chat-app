//
//  DragTextView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 27/5/2023.
//

import SwiftUI

enum StoryItemType {
    case Image
    case Text
}

struct StorySubItem : Identifiable {
    var id = UUID().uuidString
    var text : String = ""
    var isBold : Bool = false
    var type : StoryItemType = .Text
    var imageData : Data? = nil
    var offset : CGSize = .zero
    var lastOffset : CGSize = .zero
    var angle : Angle = .degrees(0)
    var lastAngle : Angle = .degrees(0)
    var scaleFactor : CGFloat = 0
    var lastScaleFactor: CGFloat = 1
    var itemSize :  CGSize = .zero
    
    //other...
    var textColor : Color = .white
    var isBorder : Bool = false
    var textAlignment : TextAlignment = .center
    var isConer : Bool = false

    
    var alignment : Alignment {
        switch(self.textAlignment){
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing :
            return .trailing
        }
    }
    
    var attributedString : AttributedString {
        var textStr = AttributedString(self.text)
        textStr.foregroundColor = self.textColor
        textStr.backgroundColor =  self.isBorder ? Color.black : Color.clear
      
        return textStr
    }
}
