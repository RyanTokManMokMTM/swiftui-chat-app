//
//  StoryPostView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/4/2023.
//

import SwiftUI
import PhotosUI

struct StoryPostView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
  
    var body: some View {
        
        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images]),photoLibrary: .shared()){
            Image(systemName: "photo.fill")
                .imageScale(.large)
                .foregroundColor( .blue)
        }
        
    }
}

struct StoryPostView_Previews: PreviewProvider {
    static var previews: some View {
        StoryPostView()
    }
}
