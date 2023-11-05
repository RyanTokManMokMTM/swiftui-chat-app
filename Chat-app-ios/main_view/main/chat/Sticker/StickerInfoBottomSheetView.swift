//
//  StickerInfoBottomSheetView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 5/11/2023.
//

import SwiftUI

struct StickerInfoBottomSheetView: View {
    var stickerId : String
    @StateObject private var hub : BenHubState = BenHubState.shared
    @EnvironmentObject private var userVM : UserViewModel
    @State private var info : StickerInfo? = nil
    @State private var isLoading : Bool = false
    
    @State private var isExist : Bool = false
    var body: some View {
        stickerHeader()
            .onAppear{
                self.isLoading = true
                Task{
                    do{
                        try await self.getStickerInfo()
                        try await self.IsUserStickerExist()
                        self.isLoading = false
                    }catch(let err){
                        hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
                    }
                }
            }
    }
    
    @ViewBuilder
    private func stickerHeader() -> some View {
        AsyncImage(url: info?.thumURL, content: { img in
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
        
        Text(info?.sticker_name ?? "--")
            .font(.system(size:25))
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .redacted(reason: self.isLoading ? .placeholder : [])
        Spacer()
        HStack{
            if !isExist {
                Button(action: {
                    Task{
                        if !isExist{
                            await self.AddSticker()
                        }
                    }
                }){
                    HStack{
                        Spacer()
                        Text("Add to my sticker")
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
            }else {
                HStack{
                    Spacer()
                    Image(systemName: "checkmark")
                        .imageScale(.medium)
                        .foregroundColor(.green)
                    Text("Aleary in your stickers")
                        .font(.system(size:14))
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.vertical,15)
                    Spacer()
                }
                .padding(.horizontal,5)
                .redacted(reason: self.isLoading ? .placeholder : [])
            }

        
        }
        .padding(.horizontal,10)
        
    }
    
    private func getStickerInfo() async throws {
        
        let resp = await  ChatAppService.shared.GetStickerInfo(stickerID: stickerId)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                self.info = data.sticker_info
            }
        case .failure(let err):
            print(err.localizedDescription)
            throw err
        }
    }
    
    private func IsUserStickerExist() async throws {
        
        let resp = await  ChatAppService.shared.IsUserStikcerExist(stickerId: stickerId)
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
        if let info = info {
            hub.SetWait(message: "Adding to your sticker...")
            let req = AddUserStickerReq(sticker_id: info.id)
            let resp = await  ChatAppService.shared.AddUserSticker(req: req)
            switch resp {
            case.success(_):
                DispatchQueue.main.async {
                    self.isExist = true
                }
                await userVM.GetUserUserStickerList()
                hub.isWaiting = false
                hub.AlertMessage(sysImg: "checkmark", message: "Sticker added.")
            case .failure(let err):
                print(err.localizedDescription)
                hub.isWaiting = false
                hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            }
        }

    }
    
}

