//
//  VoiceCallingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/2/2023.
//

import SwiftUI

struct VoiceCallingView: View {
    let data : ContentUser
    var body: some View {
        ZStack{
            AsyncImage(url: data.avatarURL, content: {img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                    .overlay{
                        BlurView(style: .systemThinMaterialDark).edgesIgnoringSafeArea(.all)
                    }
                    
            }, placeholder: {
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
            })
            
            VStack(spacing:12){
                
                HStack{
                    Button(action:{
                        
                    }){
                        Image(systemName: "chevron.down")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .scaleEffect(1.3)
                    }
                  
                    Spacer()
                }
                AsyncImage(url: data.avatarURL, content: {img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:120,height: 120)
                        .clipShape(Circle())
                       
                        
                        
                }, placeholder: {
                    ProgressView()
                        .frame(width:120,height: 120)
                       
                })
                
                Text(data.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Caling...")
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack{
                    Button(action:{}){
                        VStack(spacing:5){
                            Image(systemName: "mic.fill")
                                .imageScale(.large)
                                .scaleEffect(1.1)
                                
                            Text("Mute")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action:{}){
                        Circle()
                            .fill(.red)
                            .frame(width: 70,height: 70)
                            .overlay{
                                Image(systemName: "xmark")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                            }
                    }
                    
                    Spacer()
                    Button(action:{}){
                        VStack(spacing:5){
                            Image(systemName: "speaker.wave.2.fill")
                                .imageScale(.large)
                                .scaleEffect(1.1)
                                
                            Text("Speaker \noff")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .padding(.bottom)
            .padding(.horizontal)
            
        }

    }
}

struct VoiceCallingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceCallingView(data: dummyContentList[0])
    }
}
