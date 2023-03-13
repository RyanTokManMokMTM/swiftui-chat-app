//
//  CustomSearchBar.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchKeyWord : String
    var placeHoder : String = "Search Keyword"
    let onSubmit : () -> Void
    
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .imageScale(.large)
                .bold()
            
            TextField(placeHoder, text: $searchKeyWord)
                .onSubmit {
                    onSubmit()
                }
                .submitLabel(.search)
            
            if !searchKeyWord.isEmpty{
                Button(action:{
                    self.searchKeyWord.removeAll()
                }){
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
                .padding(5)
                .background(Color(uiColor: UIColor.systemGray5).clipShape(Circle()))
                
            }
        }
        .padding()
        .background(BlurView(style: .systemMaterial).cornerRadius(10))
        .padding(8)
        .padding(.horizontal,5)
//        .background(.red)
        
    }
}

struct CustomSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomSearchBar(searchKeyWord: .constant("")){
            print("submit")
        }
    }
}
