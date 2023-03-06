//
//  ChattingView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/2/2023.
//

import SwiftUI

struct ChattingView: View {
    let chatUserData : ContentInfo
    let messages : [MessageData]
    @Binding var isActive : Bool
    @State private var text : String = ""
    @FocusState private var isFocus : Bool
    var body: some View {
        VStack{
            ScrollView(.vertical){
                    VStack{
                        
                        ForEach(messages) { message in
                            ChatBubble(direction: message.sender == chatUserData.id ? .receiver : .sender, chatUser: chatUserData, contentType: message.content_type){
                                
                                if message.content_type == 1 {
                                    Text(message.content)
                                        .padding()
                                        .foregroundColor(Color.white)
                                        .background(Color.green)
                                }else {
                                    AsyncImage(url: message.PhotoURL, content: {img in
                                        img
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                        
                                        //                                        .background(.green)
                                    }, placeholder: {
                                        ProgressView()
                                    })
                                }
                                
                            }
                        }
                    }

                
            }
            
            InputField()
        }
        .onAppear{
            withAnimation{
                self.isActive = true
            }
            
        }.onDisappear{
            withAnimation{
                print("false")
                self.isActive = false
            }
            
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                HStack(){
//                    AsyncImage(url: chatUserData.AvatarURL, content: { img in
//                        img
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width:35,height: 35)
//                            .clipShape(Circle())
//                        
//                    }, placeholder: {
//                        ProgressView()
//                            .frame(width:35,height: 35)
//                    })
                    
                    Text(chatUserData.name)
                        .bold()
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal,5)
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                HStack{
                    Button(action:{
                        withAnimation{
                            
                        }
                    }){
                        Image(systemName: "phone.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                    Button(action:{
                        withAnimation{
                            
                        }
                    }){
                        Image(systemName: "video.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.green)
                            .bold()
                    }
                }
                
            }
        }
    }
    
    @ViewBuilder
    func InputField() -> some View{
        VStack{
            HStack{
                Button(action:{
                    //send the message
                    
                }){
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundColor( .blue)
//
//                        .disabled(message.isEmpty)
                }
                
                Button(action:{
                    //send the message
                    
                }){
                    Image(systemName: "photo.fill")
                        .imageScale(.large)
                        .foregroundColor( .blue)
//
//                        .disabled(message.isEmpty)
                }
                
                
                TextField("訊息",text:$text)
                    .padding(.horizontal)
                    .frame(height:37)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .focused($isFocus)
                    .submitLabel(.send)
                    .onSubmit{
//                        sendMessage()
                    }
                
                //Send Button
//                Button(action:{
//                    //send the message
//
//                }){
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor( .white)
//                        .frame(width: 37, height: 37)
//                        .background(
//                            Circle()
//                                .foregroundColor( .green)
//                        )
////                        .disabled(message.isEmpty)
//                }
            }
            .frame(height: 37)
        }
        .padding()
        .background(.thickMaterial)
    }
}

struct ChattingView_Previews: PreviewProvider {
    static var previews: some View {
        ChattingView(chatUserData: dummyActiveChat[0],messages: dummyChattingMessageRoom1, isActive: .constant(true))
    }
}

struct MessageData : Identifiable {
    let id = UUID().uuidString
    let sender : Int 
    let content : String
    let message_type : Int
    let content_type : Int
    let PicURL : String
    
    
    var PhotoURL : URL {
        return URL(string: PicURL)!
    }
}
