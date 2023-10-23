//
//  StickerShoeViewModel.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import Foundation
class StickerShopViewModel : ObservableObject {
    @Published var stickerList : [StickerInfo] = []
    @Published var selectStickerInfoId : String = ""
    @Published var isLoading = false
    
    func GetStickerList() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }

        let resp = await ChatAppService.shared.GetStickerGroupList()
        DispatchQueue.main.async {
            self.isLoading = false
            switch(resp){
            case .success(let data):
                self.stickerList = data.stickers
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }

}
