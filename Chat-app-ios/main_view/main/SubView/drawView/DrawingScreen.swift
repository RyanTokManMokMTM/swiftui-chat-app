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
    @Published var needToRemoveItem = false
    @Published var storyMainItem : StoryMainImageItem? = nil
    
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    
    @Published var storySubItems : [StorySubItem] = []
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
        self.isSelected = false
        self.needToRemoveItem = false
        self.toolPicker = PKToolPicker()
        self.storySubItems.removeAll()
        self.isAddText = false
        self.currentIndex = 0
        self.isDrawing = false
        self.renderImage  = nil
        self.textEditIndex = -1
    }

    func closeTextView (removeItem : StorySubItem){
//        self.toolPicker.setVisible(true, forFirstResponder: self.canvas)
//        self.canvas.becomeFirstResponder()
//
        if let index = self.storySubItems.firstIndex(where: {$0.id == removeItem.id}){
            self.textEditIndex = -1
            self.currentIndex -= 1
            removeTextBox(textBox: self.storySubItems[index])
        }
    }
    
    func removeTextBox(textBox item :  StorySubItem) {
        if let index = self.storySubItems.firstIndex(where: {$0.id == item.id}) {
            _ = self.storySubItems.remove(at: index)
            self.currentIndex = self.storySubItems.count - 1
        }
      
    }
    
    @MainActor
    func reorderTextBoxs(itemToTop item :  StorySubItem){
        if let indexOfCurrent = self.storySubItems.firstIndex(where: {$0.id == item.id}){
            self.storySubItems.remove(at: indexOfCurrent)
            self.storySubItems.append(item)
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

struct StoryMainImageItem {
    var data : Data?
    
    var offset : CGSize = .zero
    var lastOffset : CGSize = .zero
    
    var angle : Angle = .degrees(0)
    var lastAngle : Angle = .degrees(0)
    
    var scaleFactor : CGFloat = 0
    var lastScaleFactor: CGFloat = 1
    
    var isConer : Bool = false
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
    @State private var isLeadingAlignment = false
    @State private var isTralingAlignment = false
    @State private var isTopAlignment = false
    @State private var isBottomAlignment = false
    @State private var isHorizontalAlignment = false
    @State private var isVerticalAlignment = false
    
    @State private var selectedPickerItem : PhotosPickerItem? = nil

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
                        
               
                        
                        PhotosPicker(selection: $selectedPickerItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .imageScale(.medium)
                                .bold()
                                .foregroundColor(.white)
                                .padding(8)
                                .background(BlurView().clipShape(Circle()))
                        }
                        
                        Button(action:{
                            self.drawVM.storySubItems.append(StorySubItem())
                            self.drawVM.currentIndex = drawVM.storySubItems.count - 1
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
                    .opacity(self.isDragging ? 0.25 : 1)
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
            .onChange(of: self.selectedPickerItem){ newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        self.drawVM.storySubItems.append(StorySubItem(type:.Image,imageData: data))
                        self.drawVM.currentIndex = drawVM.storySubItems.count - 1
                    }
                }
            }
    }
    
    @ViewBuilder
    private func PostView(conerRadius : CGFloat = 10) -> some View {
        GeometryReader { proxy in
            let point = proxy.size
            let proxyFrame = proxy.frame(in: .global).size
            let viewHeight = proxyFrame.height / 2.4
            ZStack{
                //                    CanvasView(canvas: $drawVM.canvas,imageData: $drawVM.selecteImage, toolPikcer: $drawVM.toolPicker, rect: frame)
                Color(uiColor:UIImage(data:self.drawVM.storyMainItem!.data!)?.averageColor ?? UIColor.black)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .top)
                    .clipped()
                    .zIndex(-1)
                    
                
                Image(uiImage: UIImage(data: self.drawVM.storyMainItem!.data!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius( self.drawVM.storyMainItem!.isConer ? 10 : 0)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22, alignment: .center)
                    .rotationEffect( self.drawVM.storyMainItem!.angle)
                    .scaleEffect( self.drawVM.storyMainItem!.scaleFactor +  self.drawVM.storyMainItem!.lastScaleFactor )
                    .offset( self.drawVM.storyMainItem!.offset)
//                    .animation(.spring())
                
                    .onTapGesture {
//                        withAnimation{
                            self.drawVM.storyMainItem!.isConer.toggle()
//                        }
                    }
                    .gesture(
                        MagnificationGesture().onChanged{v in
                            self.drawVM.storyMainItem!.scaleFactor = v.magnitude - 1
                        }.onEnded{ v in
                            self.drawVM.storyMainItem!.lastScaleFactor +=  self.drawVM.storyMainItem!.scaleFactor
                            
                            self.drawVM.storyMainItem!.scaleFactor = 0
                        
                        }).simultaneousGesture(DragGesture()
                            .onChanged( { v in
                               
                                let last = self.drawVM.storyMainItem!.lastOffset
                                var new = last

                                new.width += v.translation.width
                                new.height += v.translation.height

                                self.drawVM.storyMainItem!.offset = new


                            })
                            .onEnded { v in
                                drawVM.storyMainItem!.lastOffset = drawVM.storyMainItem!.offset
                               
                            }

                        )
                        .simultaneousGesture(RotationGesture().onChanged{ v in
                            let cur = v.degrees
                            let last = self.drawVM.storyMainItem!.lastAngle
                            
                            self.drawVM.storyMainItem!.angle = .degrees(cur) + last
                        }.onEnded{ v in
                            self.drawVM.storyMainItem!.lastAngle = .degrees(v.degrees)
                        })
//                    .clipped()
                    .zIndex(0)
                
                
                if self.isDragging {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .frame(height: 25)
                        .fontWeight(self.isInTransh ? .bold : .none)
//                        .foregroundColor(self.isInTransh ? .red : .white)
                        .padding(10)
                        .background(BlurView().clipShape(Circle()))
                        .scaleEffect(self.isInTransh ? 1.2 : 1)
                        .offset(y : viewHeight)
                        .zIndex(self.isInTransh ? .infinity : 1)
                }
                
                ForEach(0..<self.drawVM.storySubItems.count,id:\.self) { id in
//                        textItem(textItem: self.drawVM.textBox[id], center: point.width / 2, heigh: viewHeight,proxyFrame : proxyFrame)
                    switch(self.drawVM.storySubItems[id].type){
                    case .Text:
                        TextItem(box: self.drawVM.storySubItems[id], center: point.width / 2, heigh: viewHeight, proxyFrame: proxyFrame, isInTransh: $isInTransh, dragginItemId: $dragginItemId,isDragging:  $isDragging,isLeadingAlignment: $isLeadingAlignment,isTralingAlignment: $isTralingAlignment,isTopAlignment: $isTopAlignment,isBottomAlignment: $isBottomAlignment,isHorizontalAlignment: $isHorizontalAlignment,isVerticalAlignment: $isVerticalAlignment)
                            .zIndex(Double(id + 2))
                            .environmentObject(drawVM)
                    case .Image:
                        ImageItemView(box: self.drawVM.storySubItems[id], center: point.width / 2, heigh: UIScreen.main.bounds.height / 1.22, proxyFrame: proxyFrame, isInTransh: $isInTransh, dragginItemId: $dragginItemId,isDragging:  $isDragging,isLeadingAlignment: $isLeadingAlignment,isTralingAlignment: $isTralingAlignment,isTopAlignment: $isTopAlignment,isBottomAlignment: $isBottomAlignment,isHorizontalAlignment: $isHorizontalAlignment,isVerticalAlignment: $isVerticalAlignment)
                            .zIndex(Double(id + 2))
                            .environmentObject(drawVM)
                    }
                    
                }
            }
            .onAppear{
                print(UIScreen.main.bounds.height / 1.22)
                print(viewHeight)
            }
            .overlay(alignment:.topTrailing,content: {
                HStack{
                    HStack{
                        AsyncImage(url: userInfo.profile!.AvatarURL, content: { img in
                            img
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width:35,height:35)
                                .clipShape(Circle())
                            
                        }, placeholder: {
                            ProgressView()
                                .frame(width:35,height:35)
                                
                        })
                        
                        VStack(alignment:.leading){
                            Text(userInfo.profile!.name)
                                .font(.system(size:15))
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("--")
                                .font(.system(size:13))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    
                }
                .padding()
                .opacity(self.isTopAlignment || self.isLeadingAlignment || self.isTopAlignment ? 1 : 0)
            }) //the close button
            .overlay(alignment:.top,content: {
                HStack(spacing:3){
                    //MARK: Story Time line0p;
                    ForEach(0..<3,id: \.self){ index in
                        GeometryReader{ reader in
                            let width = reader.size.width

                            let progress = 0.8 - CGFloat(index)
                            let percent = min(max(progress,0),1) //progress between 0 and 1
                            Capsule()
                                .fill(.gray.opacity(0.5))
                                .overlay(alignment:.leading,content: {
                                    Capsule()
                                        .fill(.white)
                                        .frame(width:width * percent)
                                })
                        }


                    }
                }
                .frame(height: 3)
                .padding(.horizontal,10)
                .opacity(self.isTopAlignment || self.isLeadingAlignment || self.isTopAlignment ? 1 : 0)
            })
            .overlay(alignment:.leading){
                BlurView(style: .systemMaterialLight)
                    .frame(width: 3)
                    .padding(.leading,10)
                    .opacity(self.isLeadingAlignment ? 1 : 0)
            }
            .overlay(alignment:.trailing){
                BlurView(style: .systemMaterialLight)
                    .frame(width: 3)
                    .padding(.trailing,10)
                    .opacity(self.isTralingAlignment ? 1 : 0)
            }
            .overlay(alignment:.top){
                BlurView(style: .systemMaterialLight)
                    .frame(height: 3)
                    .padding(.top,50)
                    .opacity(self.isTopAlignment ? 1 : 0)
            }
            .overlay(alignment:.bottom){
                BlurView(style: .systemMaterialLight)
                    .frame(height: 3)
                    .padding(.bottom,50)
                    .opacity(self.isBottomAlignment ? 1 : 0)
            }
            .overlay(alignment:.center){
                BlurView(style: .systemMaterialLight)
                    .frame(height: 3)
                    .opacity(self.isVerticalAlignment ? 1 : 0)
            }
            .overlay(alignment:.center){
                BlurView(style: .systemMaterialLight)
                    .frame(width: 3)
                    .opacity(self.isHorizontalAlignment ? 1 : 0)
            }
            
            .clipped()
            .overlay(alignment:.top){
                HStack{
                    
                    if self.drawVM.isDrawing {
                        Button(action:{
                            withAnimation{
                                self.drawVM.isDrawing = false
                            }
                            
//                            self.drawVM.toolPicker.setVisible(self.drawVM.isDrawing, forFirstResponder: self.drawVM.canvas)
//                            self.drawVM.canvas.resignFirstResponder()
//                            self.drawVM.canvas.isUserInteractionEnabled = self.drawVM.isDrawing
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
    
    
    @MainActor
    private func render() {
        let renderer = ImageRenderer(content: PostView(conerRadius: 0))
        renderer.scale = displayScale
        renderer.proposedSize = .init(CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 1.22))
        
        if let image = renderer.uiImage {
            self.drawVM.renderImage = image
        }
    }

    private func getTextBoxIndex(box : StorySubItem) -> Int {
       let index = drawVM.storySubItems.firstIndex{$0.id == box.id} ?? 0
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
