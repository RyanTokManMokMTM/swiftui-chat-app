//
//  DragTextView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 27/5/2023.
//

import SwiftUI
import PencilKit

struct TextBox : Identifiable {
    var id = UUID().uuidString
    var text : String = ""
    var isBold : Bool = false
    
    var offset : CGSize = .zero
    var lastOffset : CGSize = .zero
    //other...
    
    var textColor : Color = .white
    var isBorder : Bool = false
}

struct DragTextView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DragTextView_Previews: PreviewProvider {
    static var previews: some View {
        DragTextView()
    }
}
