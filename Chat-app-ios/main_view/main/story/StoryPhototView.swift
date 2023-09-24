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
                    .onDisappear{
                        self.drawVM.reset()
                    }
            }
            
            if self.drawVM.isAddText{
                Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
                
                
                TextField("",text: $drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].text,axis: .vertical)
                    .focused($isFocus)
                    .font(.system(size:25))
                    .fontWeight(self.drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBold ? .bold : .none)
                    .colorScheme(.dark)
                    .foregroundColor(drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textColor)
                    .padding()
                    .multilineTextAlignment(drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textAlignment)
                    .accentColor(.white)
//
                HStack{
                    Spacer()
                    Button(action:{
                        //add a text box
                        DispatchQueue.main.async {
                            self.drawVM.isAddText = false
                            if self.drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].text.isEmpty {
                                self.drawVM.needToRemoveItem = true
                                return
                            }
                            
                            self.drawVM.reorderTextBoxs(itemToTop:  self.drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex])
                            self.drawVM.textEditIndex = -1
                            
                            //                        self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
                            //                        self.drawVM.canvas.resignFirstResponder()
                           
                        }
                        
                    }){
                        Text("Done")
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .overlay{
                    HStack{
                        ColorPicker(selection: $drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textColor, supportsOpacity: false){}
                            .labelsHidden()
                        
                        
                        Button(action: {
                            withAnimation{
                                switch(drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textAlignment){
                                case .center:
                                    drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textAlignment = .leading
                                case .leading:
                                    drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textAlignment = .trailing
                                case .trailing:
                                    drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].textAlignment = .center
                                }
                                
                            }
                        }){
                            
                            Image(systemName: "text.aligncenter")
                                .imageScale(.medium)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                                .foregroundColor(.white)
                        }
//                        .buttonStyle(.)
                        
                        Button(action: {
                            withAnimation{
                                drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBorder.toggle()
                            }
                        }){
                            Image(systemName: "a.circle")
                                .imageScale(.medium)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                                .foregroundColor(.white)
                        }
//                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation{
                                self.drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex].isBold.toggle()
                            }
                        }){
                            Image(systemName: "bold")
                                .imageScale(.medium)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                                .foregroundColor(self.drawVM.storySubItems[drawVM.currentIndex].isBold ? .black : .white)
                        }
//                        .buttonStyle(.plain)
                       
                    }
                }
                .frame(maxHeight: .infinity,alignment: .top)
                .onDisappear{
                    if self.drawVM.needToRemoveItem {
                        self.drawVM.closeTextView(removeItem: self.drawVM.storySubItems[drawVM.textEditIndex != -1 ? drawVM.textEditIndex : drawVM.currentIndex])
                        self.drawVM.needToRemoveItem = false
                    }
                }
                
            }
            

        }
        .onChange(of: self.selectedPickerItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.drawVM.storyMainItem = StoryMainImageItem(data: data)
                    self.drawVM.selecteImage = data
                    self.drawVM.isSelected = true
                }
            }
        }
        .onChange(of: self.drawVM.isAddText){ v in
            if v {
                isFocus = true
            }else {
                isFocus = false
            }
        }
        .accentColor(.black)
    }
}
