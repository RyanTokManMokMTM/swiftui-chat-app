//
//  ShowImageView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/4/2023.
//

import SwiftUI

struct ShowImageView: View {
    var imageURL : String
    private let imageSaver = ImageSaver()
    @Binding var isShowImage : Bool
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageURL),content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contextMenu{
                        
                        Button {
                            let render = ImageRenderer(content: img)
                            if let uiImage = render.uiImage {
                                imageSaver.writeImageToAlbum(image: uiImage)
      
                            }
                            
                        } label: {
                            Label("Save Image", systemImage: "square.and.arrow.down")
                        }

                    }
                //                .edgesIgnoringSafeArea(.all)
            },placeholder: {
                ProgressView()
            })
        }
        .frame(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(alignment:.topLeading){
            VStack{
                Button(action:{
                    withAnimation{
                        self.isShowImage = false
                    }
                }){
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(BlurView().cornerRadius(25))
                }
            }
            .padding(.horizontal)
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)

        }
        
        

    }
}


class ImageSaver : NSObject {
    func writeImageToAlbum(image : UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted),nil)
    }
    
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}
