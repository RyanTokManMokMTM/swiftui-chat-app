//
//  ShowImageView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 19/4/2023.
//

import SwiftUI

struct ShowImageView: View {
    var imageURL : String
    @Binding var isShowImage : Bool
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageURL),content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .contextMenu{
                        
                        Button {
                            print("save image")
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
            Button(action:{
                withAnimation{
                    self.isShowImage = false
                }
            }){
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .padding(5)
                    .foregroundColor(.white)
            }
            .padding(20)
        }
        

    }
}

//struct ShowImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowImageView(imageURL: RESOURCES_HOST + "/970AC031-09A4-4DE3-A405-8EC1814D69F5.jpeg",isShowImage: .constant(false))
//    }
//}
