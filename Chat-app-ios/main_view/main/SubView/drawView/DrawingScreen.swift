//
//  DrawingScreen.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 27/5/2023.
//

import SwiftUI
import UIKit
import PhotosUI
import PencilKit

class DrawScreenViewModel : ObservableObject {
    @Published var  selecteImage : Data? = nil
    @Published var isSelected = false
    
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    
    @Published var textBox : [TextBox] = []
    @Published var isAddText : Bool = false
    
    @Published var currentIndex = 0
    @Published var isDrawing : Bool = false
    
    func cancel(){
        self.selecteImage = nil
        reset()
    }
    
    func reset() {
        self.canvas = PKCanvasView()
    }
    
    func closeTextView (){
        withAnimation{
            self.isAddText = false
        }
        self.toolPicker.setVisible(true, forFirstResponder: self.canvas)
        self.canvas.becomeFirstResponder()
        
        self.textBox.removeLast()
    }
    
}

struct CanvasView : UIViewRepresentable {
    @Binding var canvas : PKCanvasView
    @Binding var imageData : Data?
    @Binding var toolPikcer : PKToolPicker
    
    var rect : CGSize
    func makeUIView(context: Context) -> PKCanvasView{
        canvas.drawingPolicy = .anyInput
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.isUserInteractionEnabled = false
        
    
        
        if let imageData = imageData, let image = UIImage(data: imageData) {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: self.rect.width, height: self.rect.height)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true

            
            
            let subView = canvas.subviews.first! //the top subview
            subView.addSubview(imageView) //add the image to the top of the canvas
            subView.sendSubviewToBack(imageView) //push to the back

            toolPikcer.setVisible(false, forFirstResponder: canvas)
            toolPikcer.addObserver(canvas)
            canvas.resignFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {

    }
}


struct DrawingScreen: View {
    @EnvironmentObject private var drawVM : DrawScreenViewModel
    var body: some View {
        
        ZStack{
            //Canvas view
            GeometryReader { proxy -> AnyView in
                let frame = proxy.frame(in: .global).size
                return AnyView(
                    
                    ZStack{
                        CanvasView(canvas: $drawVM.canvas,imageData: $drawVM.selecteImage, toolPikcer: $drawVM.toolPicker, rect: frame)
                            .edgesIgnoringSafeArea(.all)
                        
                        ForEach(self.drawVM.textBox,id:\.id) { box in
                            Text(drawVM.textBox[self.drawVM.currentIndex].id == box.id && self.drawVM.isAddText ? "" : box.text)
                                .font(.system(size:25))
                                .foregroundColor(box.textColor)
        
                                .padding(10)
                                .background{
                                    if box.isBorder {
                                        Color.white.opacity(0.75).cornerRadius(10)
                                    }else {
                                        Color.clear
                                    }
                                }
                                .onTapGesture {
                                    drawVM.textBox[getTextBoxIndex(box: box)].isBorder.toggle()
                                }
                                .offset(box.offset)
                                .gesture(DragGesture().onChanged( { v in
                                    let cur = v.translation
                                    let last = box.lastOffset
                                    let new = CGSize(width: last.width + cur.width, height: last.height + cur.height)
                                    drawVM.textBox[getTextBoxIndex(box: box)].offset = new
                                }).onEnded( { v in
                                    drawVM.textBox[getTextBoxIndex(box: box)].lastOffset = v.translation
                                }))
   
                                
                        }
                    }
                        .overlay(alignment:.top){
                            HStack{
                                
                                if self.drawVM.isDrawing {
                                    Button(action:{
                                        withAnimation{
                                            self.drawVM.isDrawing = false
                                        }

                                        self.drawVM.toolPicker.setVisible(self.drawVM.isDrawing, forFirstResponder: self.drawVM.canvas)
                                        self.drawVM.canvas.resignFirstResponder()
                                        self.drawVM.canvas.isUserInteractionEnabled = self.drawVM.isDrawing
                                    }){
                                        Image(systemName: "checkmark")
                                            .imageScale(.large)
                                            .foregroundColor(.green)
                                            .padding(10)
                                            .background(BlurView(style: .systemChromeMaterialLight).clipShape(Circle()))
                                            
                                    }
                                    
                                    Spacer()
                                    
                                } else {
                                    Button(action:{
                                        
                                    }){
                                        Image(systemName: "arrow.left")
                                            .imageScale(.large)
                                            .foregroundColor(.green)
                                            
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action:{
                                        withAnimation{
                                            self.drawVM.isDrawing = true
                                        }
                                        
                                        
                                        self.drawVM.toolPicker.setVisible(self.drawVM.isDrawing, forFirstResponder: self.drawVM.canvas)
                                        self.drawVM.canvas.becomeFirstResponder()
                                        self.drawVM.canvas.isUserInteractionEnabled = self.drawVM.isDrawing
                                    }){
                                        Image(systemName: "pencil.circle.fill")
                                            .imageScale(.large)
                                            .foregroundColor(.green)
                                            
                                    }
                                    
                                    Button(action:{
                                        self.drawVM.textBox.append(TextBox())
                                        self.drawVM.currentIndex = drawVM.textBox.count - 1
                                        withAnimation{
                                            self.drawVM.isAddText = true
                                        }
                                        self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
                                        self.drawVM.canvas.resignFirstResponder()
                                    }){
                                        Image(systemName: "a.circle.fill")
                                            .imageScale(.large)
                                            .foregroundColor(.green)
    //                                        .padding()
                                            
                                    }
                                }
                              
                                
                            }
                            .frame(maxHeight:.infinity,alignment: .top)
                            .padding(.horizontal)
                        }
                        
                
                )
            }
        }
//        .edgesIgnoringSafeArea(.all)
//        .toolbar{
//            ToolbarItem(placement: .navigationBarTrailing){
//                Button(action:{
//
//                }){
//                    Text("post")
//                }
//            }
//
//            ToolbarItem(placement: .navigationBarTrailing){
//                Button(action:{
//
//                    self.drawVM.textBox.append(TextBox())
//                    self.drawVM.currentIndex = drawVM.textBox.count - 1
//                    withAnimation{
//                        self.drawVM.isAddText = true
//                    }
//                    self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
//                    self.drawVM.canvas.resignFirstResponder()
//
//
//                }){
//                    Text("Text")
//                }
//            }
//        }
        .onDisappear{
            self.drawVM.cancel()
        }

    }
    
    
   private func getTextBoxIndex(box : TextBox) -> Int {
       let index = drawVM.textBox.firstIndex{$0.id == box.id} ?? 0
       return index
    }
}

struct DrawingScreen_Previews: PreviewProvider {
    static var previews: some View {
        StoryPhotot2View()
    }
}


struct Story2PhototView: View {
    @State private var selectedData : PhotosPickerItem? = nil
    @State private var selecteImage : Data? = nil
    @State private var isSelected = false
    
    @Binding var isAddStory : Bool
    var body: some View {
       Text("d")
    }
}
