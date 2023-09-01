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
    @EnvironmentObject private var userInfo : UserViewModel
    @StateObject private var drawVM = DrawScreenViewModel()
    @State private var selectedPickerItem : PhotosPickerItem? = nil
    @FocusState private var isFocus : Bool
//
    @Binding var isAddStory : Bool
    var body: some View {
        ZStack {
            PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                Label("Select a photo", systemImage: "photo")
                  
            }  
            .tint(.green)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
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
            
            
            if self.drawVM.isSelected {
                DrawingScreen(isAddStory:$isAddStory).environmentObject(self.drawVM)
                    .environmentObject(self.drawVM)
                    .environmentObject(self.userStory)
                    .environmentObject(self.userInfo)
                    .transition(.move(edge: .trailing))
                    .background(Color.white.edgesIgnoringSafeArea(.all))
            }
            
            if self.drawVM.isAddText {
                Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)

                TextField("Type Here",text: $drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].text,axis: .vertical)
                    .focused($isFocus)
                    .font(.system(size:25))
                    .fontWeight(self.drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBold ? .bold : .none)
                    .colorScheme(.dark)
                    .foregroundColor(drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textColor)
                    .padding()

                HStack{
                    Spacer()
                    Button(action:{
                        //add a text box
                        if self.drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].text.isEmpty {
                            self.drawVM.closeTextView()
                            self.drawVM.textEditIndex = -1
                            self.drawVM.currentIndex -= 1
                            return
                        }
                        self.drawVM.currentMaxOrder += 1
                        self.drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].order =  self.drawVM.currentMaxOrder
                        self.drawVM.textEditIndex = -1
//                        self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
//                        self.drawVM.canvas.resignFirstResponder()
                        self.drawVM.isAddText = false
                    }){
                        Text("Done")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .overlay{
                    HStack{
                        ColorPicker(selection: $drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textColor, supportsOpacity: false){}
                            .labelsHidden()
                        
                        
                        Button(action: {
                            withAnimation{
                                drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBorder.toggle()
                            }
                        }){
                            Image(systemName: "a.circle")
                                .imageScale(.large)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation{
                                self.drawVM.textBox[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBold.toggle()
                            }
                        }){
                            Image(systemName: "bold")
                                .imageScale(.large)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                                .foregroundColor(self.drawVM.textBox[drawVM.currentIndex].isBold ? .black : .white)
                        }
                       
                    }
                }
                .frame(maxHeight: .infinity,alignment: .top)
                .onChange(of: self.drawVM.isAddText){ v in
                    if v {
                        isFocus = true
                    }else {
                        isFocus = false
                    }
                }
                
            }

        }
        .onChange(of: self.selectedPickerItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.drawVM.selecteImage = data
                    self.drawVM.isSelected = true
                }
            }
        }
        .accentColor(.black)
    }
}
