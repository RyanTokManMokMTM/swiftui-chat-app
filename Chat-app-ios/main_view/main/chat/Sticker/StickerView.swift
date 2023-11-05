//
//  StickerView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/5/2023.
//

import SwiftUI

struct StickerView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var stickerShopVM : StickerShopViewModel
    @State private var isOpenShop = false
    @Namespace private var namespace
    
    
    var onSend : (String,String) -> Void
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
                        ForEach(0..<self.userVM.userStickerList.count, id: \.self) { i in
                            AsyncImage(url: self.userVM.userStickerList[i].thumURL, content: { img in
                                img
                                    .resizable()
                                    .frame(width: 30,height: 30)
                                    .aspectRatio(contentMode: .fill)
                                    .padding(5)
                                    .background(BlurView(style: .systemUltraThinMaterialLight).opacity(self.self.userVM.userStickerIndex == i ? 1:0).cornerRadius(10))
                                    .onTapGesture {
                                        self.userVM.userStickerIndex = i
                                    }
                            }, placeholder: {
                                ProgressView()
                                    .frame(width: 30,height: 30)
                            })
                        }
                    }
                    //                    .frame(width: 30,height: 30)
                    //                    .padding(.horizontal,5)
                }
            }
            
            if !self.userVM.userStickerList.isEmpty {
                StickerSubView(stickerId: self.userVM.userStickerList[self.userVM.userStickerIndex].id,onSend: onSend)
            }else {
                VStack{
                    Text("No sticker yet.")
                        .foregroundColor(.gray)
                        .italic()
                }
                .frame(maxHeight:UIScreen.main.bounds.height / 2.5)
            }
            
        }
        .fullScreenCover(isPresented: $isOpenShop){
            StickerShopView()
                .environmentObject(stickerShopVM)
                .environmentObject(userVM)
        }
    }

}


struct StickerSubView: View {
    var stickerId : String
    @State private var isDownloading : Bool = false
    @State private var stickerGroup : StickerGroup? = nil
    @Namespace private var namespace
    
    var onSend : (String,String) -> Void
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
                                       
                                            if let path = sticker.path,let id = sticker.relationship?.id {
                                                onSend(path,id.uuidString)
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
        .onChange(of: self.stickerId){ id in
            self.stickerGroup = nil
            isStickerGroupExist(id: id)
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
        let resp = await  ChatAppService.shared.GetStickerGroupResources(stickerID: stickerId)
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
