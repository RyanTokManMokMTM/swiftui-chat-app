//
//  StoryPhototView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/4/2023.
//

import SwiftUI
import PhotosUI

struct StoryPhototView: View {
    @EnvironmentObject private var userStory : UserStoryViewModel
    @StateObject private var svm = StoryPostModel()
    @State private var selectedData : PhotosPickerItem? = nil
    @State private var selecteImage : Data? = nil
    @State private var isSelected = false
    
    @Binding var isAddStory : Bool
    var body: some View {
        NavigationStack{
//            if self.selecteImage != nil {
            NavigationLink(destination:postStoryImageView(isCreatePost: $isAddStory).environmentObject(self.svm).environmentObject(userStory),isActive: self.$svm.isSelected){
                PhotosPicker(selection: $selectedData, matching: .images) {
                    Label("Select a photo", systemImage: "photo")
                      
                }
                .tint(.purple)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                
                
                
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .overlay(alignment:.topLeading){
                Button(action:{
                    withAnimation{
                        self.isAddStory = false
                    }
                }){
                    HStack{
                        Image(systemName: "xmark")
                            .imageScale(.large)
                    }
                    
                }
                .padding(.horizontal)
            }
//            }
            
        }
        .padding(.horizontal)
        .onChange(of: self.selectedData){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.svm.imageData = data
                    self.svm.isSelected = true
                }
            }
        }

    }
}

//struct StoryPhototView_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryPhototView()
//    }
//}

struct postStoryImageView : View {
    @EnvironmentObject private var svm : StoryPostModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @Binding var isCreatePost : Bool
    var body: some View {
        VStack{
            if let data = self.svm.imageData {
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    print("Post a story")
                    Task {
                        await createStory()
                    }
                    withAnimation{
                        self.isCreatePost = false
                    }
                }){
                    Text("Post")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
            
        }
    
    }
    
    private func createStory() async{
        let resp = await ChatAppService.shared.CreateStory(mediaData: self.svm.imageData!)
        switch resp {
        case .success(let data):
            print(data.story_id)
            DispatchQueue.main.async {
                self.userStory.userStories.append(UInt(data.story_id))
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
}

final class StoryPostModel : ObservableObject {
    @Published var imageData : Data?
    @Published var isSelected = false
}
