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

    @Published var renderImage : UIImage? = nil

    @Published var textEditIndex : Int = -1
    
    func cancel(){
        self.selecteImage = nil
        self.renderImage = nil
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
    
    func remoteTextBox(textBox item :  TextBox) {
        if let index = self.textBox.firstIndex(where: {$0.id == item.id}) {
            _ = self.textBox.remove(at: index)
            self.currentIndex = self.textBox.count - 1
        }
      
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
            imageView.frame = CGRect(x: 0, y: 0, width: self.rect.width, height: UIScreen.main.bounds.height)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            
            let subView = canvas.subviews.first! //the top subview
            subView.addSubview(imageView) //add the image to the top of the canvas
            subView.sendSubviewToBack(imageView) //push to the back

//            toolPikcer.setVisible(false, forFirstResponder: canvas)
//            toolPikcer.addObserver(canvas)
            canvas.resignFirstResponder()
        }
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {

    }
}


struct DrawingScreen: View {
    @EnvironmentObject private var drawVM : DrawScreenViewModel
    @EnvironmentObject private var userInfo : UserViewModel
    @EnvironmentObject private var userStory : UserStoryViewModel
    @StateObject private var hub = BenHubState.shared
    
    @Environment(\.displayScale) var displayScale
    
    @Binding var isAddStory : Bool
    @State private var isDragging : Bool = false
    @State private var isInTransh : Bool = false
    @State private var dragginItemId : String = ""
    
    var body: some View {
        PostView()
            .overlay(alignment:.top){
                if !self.drawVM.isDrawing{
                    HStack{
                        Button(action:{
                            self.drawVM.isSelected = false
                            self.drawVM.reset()
                        }){
                            Image(systemName: "arrow.left")
                                .imageScale(.large)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                            
                        }
                        
                        Spacer()
                        
                        //                        Button(action:{
                        ////                            withAnimation{
                        ////                                self.drawVM.isDrawing = true
                        ////                            }
                        ////
                        ////
                        ////                            self.drawVM.toolPicker.setVisible(self.drawVM.isDrawing, forFirstResponder: self.drawVM.canvas)
                        ////                            self.drawVM.canvas.becomeFirstResponder()
                        ////                            self.drawVM.canvas.isUserInteractionEnabled = self.drawVM.isDrawing
                        //                        }){
                        //                            Image(systemName: "pencil.tip")
                        //                                .imageScale(.large)
                        //                                .bold()
                        //                                .foregroundColor(.white)
                        //                                .padding(8)
                        //                                .background(BlurView().clipShape(Circle()))
                        //
                        //                        }
                        
                        Button(action:{
                            self.drawVM.textBox.append(TextBox())
                            self.drawVM.currentIndex = drawVM.textBox.count - 1
                            withAnimation{
                                self.drawVM.isAddText = true
                            }
                            self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
                            self.drawVM.canvas.resignFirstResponder()
                            
                            
                        }){
                            Image(systemName: "character")
                                .imageScale(.large)
                                .bold()
                                .foregroundColor(.white)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                            //                                        .padding()
                            
                        }
                        
                    }
                    .padding()
                }
                
            }
            .overlay(alignment:.bottom){
                if !self.drawVM.isDrawing{
                    HStack{
                        Spacer()
                        Button(action:{
                            render()
                            Task{
                                await createStory()
                            }
                            
                            withAnimation{
                                self.isAddStory = false
                            }
                        }){
                            HStack(spacing:15){
                                AsyncImage(url: userInfo.profile?.AvatarURL ?? URL(string: "")!, content: { img in
                                    
                                    img
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                    
                                }, placeholder: {
                                    ProgressView()
                                    
                                })
                                Text("Share to your story")
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .ignoresSafeArea(.keyboard)
                                
                            }
                            .padding(10)
                            .background(BlurView().clipShape(CustomConer(coners: .allCorners)))
                            
                        }
                        
                        Spacer()
                    }
                    .padding(.top,5)
                    .padding(.horizontal)
                }
                
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    @ViewBuilder
    private func PostView(conerRadius : CGFloat = 10) -> some View {
        GeometryReader { proxy  in
            let proxyFrame = proxy.frame(in: .global).size
            let viewHeight = proxyFrame.height / 2.4
            let center = 0.0
            ZStack{
                //                    CanvasView(canvas: $drawVM.canvas,imageData: $drawVM.selecteImage, toolPikcer: $drawVM.toolPicker, rect: frame)
                Image(uiImage: UIImage(data: drawVM.selecteImage!)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .top)
                    .clipped()
                    .zIndex(0)
                
                
                if self.isDragging {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .fontWeight(self.isInTransh ? .bold : .none)
                        .foregroundColor(self.isInTransh ? .red : .white)
                        .padding(8)
                        .background(BlurView().clipShape(Circle()))
                        .scaleEffect(self.isInTransh ? 1.2 : 1)
                        .offset(y : viewHeight)
                        .zIndex(self.isInTransh ? .infinity : 1)
                }
                
                ForEach(self.drawVM.textBox,id:\.id) { box in
                    textItem(textItem: box, centerPos: center, viewHeight: viewHeight)
                }
                .zIndex(2)
            }
            .clipped()
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
                        //                                    Button(action:{
                        //
                        //                                    }){
                        //                                        Image(systemName: "arrow.left")
                        //                                            .imageScale(.large)
                        //                                            .foregroundColor(.green)
                        //
                        //                                    }
                        //
                        //                                    Spacer()
                        //
                        //                                    Button(action:{
                        //                                        withAnimation{
                        //                                            self.drawVM.isDrawing = true
                        //                                        }
                        //
                        //
                        //                                        self.drawVM.toolPicker.setVisible(self.drawVM.isDrawing, forFirstResponder: self.drawVM.canvas)
                        //                                        self.drawVM.canvas.becomeFirstResponder()
                        //                                        self.drawVM.canvas.isUserInteractionEnabled = self.drawVM.isDrawing
                        //                                    }){
                        //                                        Image(systemName: "pencil.circle.fill")
                        //                                            .imageScale(.large)
                        //                                            .foregroundColor(.green)
                        //
                        //                                    }
                        //
                        //                                    Button(action:{
                        //                                        self.drawVM.textBox.append(TextBox())
                        //                                        self.drawVM.currentIndex = drawVM.textBox.count - 1
                        //                                        withAnimation{
                        //                                            self.drawVM.isAddText = true
                        //                                        }
                        //                                        self.drawVM.toolPicker.setVisible(false, forFirstResponder: self.drawVM.canvas)
                        //                                        self.drawVM.canvas.resignFirstResponder()
                        //                                    }){
                        //                                        Image(systemName: "a.circle.fill")
                        //                                            .imageScale(.large)
                        //                                            .foregroundColor(.green)
                        //    //                                        .padding()
                        //
                        //                                    }
                    }
                    
                    
                }
                .frame(maxHeight:.infinity,alignment: .top)
                .padding(.horizontal)
            }
            .cornerRadius(conerRadius)
            
            
        }
    }
    
    @ViewBuilder
    private func textItem(textItem box : TextBox,centerPos : CGFloat,viewHeight : CGFloat) -> some View {
        Text(drawVM.textBox[self.drawVM.currentIndex].id == box.id && self.drawVM.isAddText ? "" : box.text)
            .font(.system(size:20)) //TODO: Can be modify soon...
            .foregroundColor(box.textColor)
            .fontWeight(box.isBold ? .bold : .none)
            .padding(10)
            .background{
                if box.isBorder {
                    Color.black.opacity(0.65).cornerRadius(10)
                }else {
                    Color.clear
                }
            }
            .scaleEffect(self.isInTransh && self.dragginItemId == box.id ? 0.4 : 1)
            .transition(.scale)
            .offset(box.offset)
            .onTapGesture {
                if let idx = self.drawVM.textBox.firstIndex(where: {$0.id == box.id}){
                    self.drawVM.textEditIndex = idx
                    self.drawVM.isAddText = true
                }
            }
            .gesture(DragGesture().onChanged( { v in
                let cur = v.translation
                let last = box.lastOffset
                let new = CGSize(width: last.width + cur.width, height: last.height + cur.height)
                drawVM.textBox[getTextBoxIndex(box: box)].offset = new
                
                //                            print("is dragging....")
                if !self.isDragging  {
                    //                                withAnimation{
                    self.isDragging = true
                    //                                }
                    self.dragginItemId = box.id
                }
                
                let left = centerPos - 20
                let right = centerPos + 20
                let top = viewHeight - 20
                let bottom = viewHeight + 20

                if new.height >= top && new.height <= bottom && new.width >= left && new.width <= right {
                    withAnimation{
                        self.isInTransh = true
                    }
                } else {
                    withAnimation{
                        self.isInTransh = false
                    }
                }
                
            }).onEnded( { v in
                drawVM.textBox[getTextBoxIndex(box: box)].lastOffset = v.translation
                if self.isDragging {
                    //                                withAnimation{
                    self.isDragging = false
                    //                                }
                    self.dragginItemId = ""
                    if self.isInTransh {
                        self.drawVM.remoteTextBox(textBox: box)
                        self.isInTransh = false
                    }
                }
            }))
            .opacity(self.drawVM.isAddText && self.drawVM.textBox[self.drawVM.textEditIndex != -1 ? self.drawVM.textEditIndex : self.drawVM.currentIndex].id == box.id ? 0 : 1)
        
    }

    
    @MainActor
    private func render() {
        let renderer = ImageRenderer(content: PostView(conerRadius: 0))
        renderer.scale = displayScale
        renderer.proposedSize = .init(CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22))
        
        if let image = renderer.uiImage {
            self.drawVM.renderImage = image
        }
    }

    private func getTextBoxIndex(box : TextBox) -> Int {
       let index = drawVM.textBox.firstIndex{$0.id == box.id} ?? 0
       return index
    }
    
    private func createStory() async{
        guard let imageData = self.drawVM.renderImage!.pngData() else {
            return
        }
      
        let resp = await ChatAppService.shared.CreateStory(mediaData: imageData)
        switch resp {
        case .success(let data):
            hub.AlertMessage(sysImg: "checkmark", message: "Posted")
            DispatchQueue.main.async {
                self.userStory.userStories.append(UInt(data.story_id))
            }

        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            print(err.localizedDescription)
        }
    }
  
}


//
//struct DrawingScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        StoryPhotot2View()
//    }
//}

