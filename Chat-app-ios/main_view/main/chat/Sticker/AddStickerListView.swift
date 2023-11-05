//
//  AddStickerListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import SwiftUI

struct AddStickerListView: View {
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject private var userVM : UserViewModel
    var info : StickerInfo
//    var stickerPath : []
    @State private var isLoading = false
    @State private var isExist : Bool = false
    @State private var resources : [String] = []
    
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        ScrollView(.vertical){
            stickerHeader()
            Spacer()
            Divider()
                .padding(.horizontal,10)
                
            stickerList()
                
        }
        .onAppear{
            self.isLoading = true
            Task{
                do {
                    try await GetSticker()
                    try await IsUserStickerExist()
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                } catch(let err){
                    print(err)
                }
//                await GetSticker()
               
            }
        }

    }
    
    @ViewBuilder
    
    private func stickerHeader() -> some View {
        AsyncImage(url: info.thumURL, content: { img in
            img
                .resizable()
                .scaledToFit()
                .frame(width:120,height: 120)
                .aspectRatio(contentMode: .fit)
                .redacted(reason: self.isLoading ? .placeholder : [])
            
            
        }, placeholder: {
            ProgressView()
                .scaledToFit()
                .frame(width:120,height: 120)
                .aspectRatio(contentMode: .fit)
        })
        
        Text(info.sticker_name)
            .font(.system(size:25))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .redacted(reason: self.isLoading ? .placeholder : [])
        
        HStack{
            
            Button(action: {
                Task{
                    if isExist{
                        await self.DeleteSticker()
                    }else {
                        await self.AddSticker()
                    }
                }
            }){
                HStack{
                    Spacer()
                    Text(self.isExist ? "Remove from my sticker": "Add to my sticker")
                        .font(.system(size:14))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.vertical,15)
                    Spacer()
                }
                .background(self.isExist ? Color.red : Color.green)
                .cornerRadius(10)
                .padding(.horizontal,5)
                .redacted(reason: self.isLoading ? .placeholder : [])
            }
           
        
        }
        .padding(.horizontal,10)
        
    }
    
    @ViewBuilder
    private func stickerList() -> some View {
        VStack{
            if self.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            }else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(self.resources, id: \.self) { sticker in
                        AsyncImage(url:  URL(string: RESOURCES_HOST + "/sticker/" + sticker)!) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            case .failure:
                                
                                //Call the AsynchImage 2nd time - when there is a failure. (I think you can also check NSURLErrorCancelled = -999)
                                AsyncImage(url: URL(string: RESOURCES_HOST + "/sticker/" + sticker)!) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
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
                        .redacted(reason: self.isLoading ? .placeholder : [])
                    }
                }
                .padding(10)
            }
        }
      
    }
    
    private func GetSticker() async throws {
//        self.isLoading = true
        let resp = await  ChatAppService.shared.GetStickerGroup(stickerID: info.id)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                self.resources = data.resources_path
//                self.isLoading = false
            }
        case .failure(let err):
            print(err.localizedDescription)
            throw err
        }
    }
    
    private func IsUserStickerExist() async throws {
        let resp = await  ChatAppService.shared.IsUserStikcerExist(sticker_id: info.id)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                self.isExist = data.is_exist
            }
        case .failure(let err):
            print(err.localizedDescription)
            throw err
        }
    }
    
    private func AddSticker() async{
        hub.SetWait(message: "Adding to your sticker...")
        let req = AddUserStickerReq(sticker_id: info.id)
        let resp = await  ChatAppService.shared.AddUserSticker(req: req)
        switch resp {
        case.success(_):
            DispatchQueue.main.async {
                self.isExist = true
            }
            await self.userVM.GetUserUserStickerList()
            hub.isWaiting = false
            hub.AlertMessage(sysImg: "checkmark", message: "Sticker added.")
        case .failure(let err):
            print(err.localizedDescription)
            hub.isWaiting = false
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
    private func DeleteSticker() async{
        hub.SetWait(message: "Removing from your sticker...")
        let req = DeleteUserStickerReq(sticker_id: info.id)
        let resp = await  ChatAppService.shared.DeleteUserSticker(req: req)
        switch resp {
        case.success(_):
            DispatchQueue.main.async {
                self.isExist = false
            }
            await self.userVM.GetUserUserStickerList()
            hub.isWaiting = false
            hub.AlertMessage(sysImg: "checkmark", message: "Sticker added.")
        case .failure(let err):
            print(err.localizedDescription)
            hub.isWaiting = false
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
}
