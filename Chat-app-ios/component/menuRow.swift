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
            .background( RoundedRectangle(cornerRadius: 13).fill(self.tagIndex == self.selected ? Color(uiColor: UIColor.systemGray6) : .clear).frame(width: UIScreen.main.bounds.width / 1.2 - 30,height: 60))
            .frame(height:55)
            .onTapGesture {
                action()
            }
//        }
//        .buttonStyle(.plain)
  
     
    }
}

struct menuRow_Previews: PreviewProvider {
    static var previews: some View {
        menuRow(tagIndex:0,sysImg: "magnifyingglass", rowName: "Find Friend", selected: .constant(0)){
            print("....")
        }
    }
}
