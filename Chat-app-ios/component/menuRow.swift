//
//  menuRow.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI

struct menuRow: View {
    let tagIndex : Int
    let sysImg : String
    let rowName : String
    @Binding var selected :Int
    var namespace : Namespace.ID
    let action : () -> ()
    var body: some View {
//        Button(action: action){
            HStack(spacing:18){
                Image(systemName: sysImg)
                    .imageScale(.medium)
                    .bold()
                    .background( RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: UIColor.systemGray5)).frame(width: 35,height: 35))

                Text(rowName)
                    .font(.body)
                    .bold()
                Spacer()
            }
            .padding(.horizontal,30)
            .background(backgroupView())
            .frame(height:55)
            .onTapGesture {
                action()
            }
//        }
//        .buttonStyle(.plain)
  
     
    }
    
    @ViewBuilder
    private func backgroupView() -> some View {
        if self.tagIndex == self.selected {
            RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: UIColor.systemGray6)).frame(width: UIScreen.main.bounds.width / 1.2 - 30,height: 60)
                .matchedGeometryEffect(id: "menu", in: namespace,isSource: true)
        }else {
            RoundedRectangle(cornerRadius: 13).fill(Color.clear).frame(width: UIScreen.main.bounds.width / 1.2 - 30,height: 60)
                .matchedGeometryEffect(id: "menu", in: namespace,isSource: false)
        }
    }
}

