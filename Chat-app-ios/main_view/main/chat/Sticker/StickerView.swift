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
    Sticker(id: "d87b9eb9-8c77-4886-82af-87535f75ed59", thrumb: "d87b9eb9-8c77-4886-82af-87535f75ed59"),
]

struct StickerPaths : Identifiable{
    let id = UUID().uuidString
    let path : String
    var StickerURL : URL {
        return URL(string:  RESOURCES_HOST + self.path)!
    }
}

struct StickerView: View {
    @EnvironmentObject var stickerShopVM : StickerShopViewModel
    @State private var index = 0
    @State private var isOpenShop = false
    @Namespace private var namespace
    
    
    var onSend : (String) -> Void
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        VStack{
            HStack{
                Button(action:{
                    self.isOpenShop = true
                    Task{
                       await self.stickerShopVM.GetStickerList()
                    }
                }){
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                        .frame(width: 30,height: 30)
                        .bold()
                }
                .foregroundColor(.green)
                
                ScrollView(.horizontal,showsIndicators: false){
                    HStack(spacing:0){
                        ForEach(0..<stickers.count, id: \.self) { i in
                            Image(stickers[i].thrumb)
                                .resizable()
                                .frame(width: 30,height: 30)
                                .aspectRatio(contentMode: .fill)
                                .padding(5)
                                .background(BlurView(style: .systemUltraThinMaterialLight).opacity(self.index == i ? 1:0).cornerRadius(10))
                        }
                    }
                    .frame(width: 30,height: 30)
                    .padding(.horizontal,5)
                }
            }
            
            
            StickerSubView(stickerId: stickers[index].id,onSend: onSend)
        }
        .fullScreenCover(isPresented: $isOpenShop){
            StickerShopView()
                .environmentObject(stickerShopVM)
        }
    }

}


struct StickerSubView: View {
    var stickerId : String
//    @State private var isStickerExisted : Bool = false
    @State private var isDownloading : Bool = false
    @State private var stickerGroup : StickerGroup? = nil
    @Namespace private var namespace
    
    var onSend : (String) -> Void
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        VStack{
            if self.isDownloading {
                HStack{
                    Spacer()
                    ProgressView()
                    Text("Downloading...")
                        .font(.system(size:14))
                        .foregroundColor(.gray)
                        .padding(.horizontal,5)
                    Spacer()
                }
            }else {
                if let sticker = self.stickerGroup {
                    
                    ScrollView {
    //                    if let resource = sticker.re
                        if let resources  = sticker.resoucres?.allObjects as? [StickerGroupResources] {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(resources, id: \.id) { sticker in
                                    Image(uiImage: UIImage(data: sticker.imageData!)!) //need safty checking..
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            if let path = sticker.path {
                                                onSend(path)
                                            }
                                        }

                                }
                            }
                        }
                       
                    }
                    
                }else {
                    HStack{
                        Spacer()
                        Button(action: {
                            Task{
                                await GetSticker()
                            }
                        }){
                            Text("Download the sticker.")
                                .font(.system(size:14))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color.blue.cornerRadius(10))
                        Spacer()
                    }
                    
                }
            }

        }
        .frame(maxHeight:UIScreen.main.bounds.height / 2.5)
        .onAppear{
            isStickerGroupExist(id: stickerId)
        }
    }
    
    @MainActor
    private func isStickerGroupExist(id : String) {
        if let sticker = UserDataModel.shared.findStickerGroup(stickerId: UUID(uuidString: id)!){
            stickerGroup = sticker
        }
    }

    private func GetSticker() async {
        self.isDownloading = true
        let resp = await  ChatAppService.shared.GetStickerGroup(stickerID: stickerId)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                Task {
                    do{
                        let sticker = try await UserDataModel.shared.createStickerGroup(stickerId: data.stickerUUID, resources: data.resources_path)
                        self.stickerGroup = sticker
                    } catch(let err){
                        print(err.localizedDescription)
                    }
                   
                    self.isDownloading = false
                }

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
