//
//  StickerView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/5/2023.
//

import SwiftUI

struct Sticker : Identifiable{
    let id : String
    let thrumb : String
}

let stickers : [Sticker] = [
    Sticker(id: "9480a1ee-3ea7-4a0b-a14e-b436e050a997", thrumb: "9480a1ee-3ea7-4a0b-a14e-b436e050a997"),
    Sticker(id: "a0234e3b-df42-4524-bc30-bf9832ae2e6d", thrumb: "a0234e3b-df42-4524-bc30-bf9832ae2e6d"),
    Sticker(id: "a69dedcc-51ec-4887-b9a4-12a7774356c3", thrumb: "a69dedcc-51ec-4887-b9a4-12a7774356c3")
]

struct StickerPaths : Identifiable{
    let id = UUID().uuidString
    let path : String
    var StickerURL : URL {
        return URL(string:  RESOURCES_HOST + self.path)!
    }
}

struct StickerView: View {
    @State private var index = 0
    @State private var paths : [StickerPaths] = []
    @State private var isFecthing : Bool = false
    @Namespace private var namespace
    
    var onSend : (String) -> Void
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        VStack{
            ScrollView(.horizontal,showsIndicators: false){
                HStack(spacing:0){
                    ForEach(0..<stickers.count, id: \.self) { i in
                        Image(stickers[i].thrumb)
                            .resizable()
                            .frame(width: 30,height: 30)
                            .aspectRatio(contentMode: .fill)
                            .padding(5)
                            .onTapGesture {
                                withAnimation{
                                    self.index = i
                                    Task {
                                        await GetSticker()
                                    }
                                }
                            }
//                            .matchedGeometryEffect(id: "sticker", in: namespace)
                            .background(BlurView(style: .systemUltraThinMaterialLight).opacity(self.index == i ? 1:0).cornerRadius(10))
                    }
                }
                .padding(.horizontal)
            }
            ScrollView {
                if self.isFecthing {
                    ProgressView()
                }else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(self.paths, id: \.id) { sticker in
                            AsyncImage(url: sticker.StickerURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            print("sending sticker \(sticker.path)")
                                            onSend(sticker.path)
                                        }
                                    
                                case .failure:
                                    
                                    //Call the AsynchImage 2nd time - when there is a failure. (I think you can also check NSURLErrorCancelled = -999)
                                    AsyncImage(url: sticker.StickerURL) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .onTapGesture {
                                                    print("sending sticker \(sticker.path)")
                                                    onSend(sticker.path)
                                                }
                                        } else{
                                            Image(systemName: "xmark.octagon")
                                        }
                                    }
                                    
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    ProgressView()
                                }
                                
                                 
                             }
                            
//
//                            AsyncImage(url: sticker.StickerURL, content: { img in
//                                img
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .onTapGesture {
//                                        print("sending sticker \(sticker.path)")
//                                        onSend(sticker.path)
//                                    }
//                            }, placeholder: {
//                                ProgressView()
//                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxHeight:UIScreen.main.bounds.height / 2.5)
        }
        .onAppear{
            Task{
                await GetSticker()
            }
        }
    }
    
    private func GetSticker() async {
        self.isFecthing = true
        let resp = await  ChatAppService.shared.GetStickerGroup(stickerID: stickers[self.index].id)
        
        self.isFecthing = false
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                var resources : [StickerPaths] = []
                data.resources_path.forEach{ resources.append(StickerPaths(path: $0)) }
//                print(resources)
                self.paths = resources
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
}

//struct StickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        StickerView()
//    }
//}
