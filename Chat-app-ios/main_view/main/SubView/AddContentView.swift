//
//  AddContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 24/5/2023.
//

import SwiftUI

struct AddContentView<Content : View>: View {
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    let content : () -> Content
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            content()
        }
        .frame(maxHeight:UIScreen.main.bounds.height / 8)
    }

}

//struct AddContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddContentView()
//    }
//}
