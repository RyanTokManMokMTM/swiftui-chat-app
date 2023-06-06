//
//  ShareView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 27/5/2023.
//

import SwiftUI


struct WallPaperGroup : Identifiable{
    let id = UUID().uuidString
    let color : Color
    let wallPaper : String
}

struct ShareView: View {
    
    let wallPaper = [
        WallPaperGroup(color: Color("wallpaper1Color"), wallPaper: "wallpaper1"),
        WallPaperGroup(color: Color("wallpaper2Color"), wallPaper: "wallpaper2"),
        WallPaperGroup(color: Color("wallpaper3Color"), wallPaper: "wallpaper3")
    ]
    
    @State private var currentIndex = 0
    @State private var text : String = ""
    @State private var box = TextBox()
    var body: some View {
        VStack{
            ZStack(alignment:.center){
                Image(wallPaper[self.currentIndex].wallPaper)
                    .resizable()
                    .clipped()
                    .clipShape(CustomConer(coners: [.bottomLeft,.bottomRight]))
//                    .edgesIgnoringSafeArea(.all)

                HStack{
                    Button(action:{

                    }){
                      Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .padding()

                    }

                    Spacer()

                    Button(action:{

                    }){
                       Text("Next")
                              .imageScale(.large)
                              .foregroundColor(.green)
                              .padding()
                              .background(BlurView(style: .systemMaterialLight).cornerRadius(10))
                    }
                }
                .padding()
                .overlay{
                    ColorPicker(selection:$box.textColor, supportsOpacity: false){}
                        .labelsHidden()
                }
                .frame(maxHeight:.infinity,alignment:.top)
                .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                
                HStack{
                    TextField("Input you want to share",text: $box.text)
                        .padding()
                        .foregroundColor(box.textColor)
                        .font(.system(size:25))
                }
                .offset(box.offset)
                .gesture(DragGesture().onChanged( { v in
                    let new = v.translation
                    let offset = box.lastOffset
                    box.offset = CGSize(width: offset.width + new.width, height: offset.height + new.height)
                }).onEnded({ v in
                    box.lastOffset = v.translation
                }))
                
                HStack{
                    ForEach(wallPaper.indices,id :\.self) { i in
                        colorButton(color: wallPaper[i].color, index: i)
                    }
                }
                .padding()
                .background(BlurView().cornerRadius(50))
                .frame(maxHeight:.infinity,alignment:.bottom)
                .padding()
            }
            HStack(alignment:.top){
                VStack{
                    Image(systemName: "textformat.size.larger")
                        .bold()
                        .imageScale(.large)
                    Circle()
                        .fill(.red)
                        .frame(width:5)
                }
                
                VStack{
                    Image(systemName: "photo")
                        .bold()
                        .imageScale(.large)
                }
            }
            .padding(.bottom,10)
            .padding(.vertical,5)
            .foregroundColor(.white)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)

//        .ignoresSafeArea()
     
    }
    
    @ViewBuilder
    private func colorButton(color: Color,index : Int) -> some View {
        Circle()
            .fill(color)
            .frame(width: 25)
            .onTapGesture {
                withAnimation{
                    currentIndex = index
                }
            }
            .overlay{
                if self.currentIndex == index {
                    RoundedRectangle(cornerRadius: 25,style: .circular)
                        .stroke(.red,lineWidth: 2)
                        .transition(.identity)
                    
                }
            }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView()
    }
}
