//
//  AddStickerListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import SwiftUI

struct AddStickerListView: View {
    var info : StickerInfo
//    var stickerPath : []
    @State private var isLoading = false
    @State private var resources : [String] = []
    
    let columns = Array(repeating: GridItem(spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        ScrollView(.vertical){
            stickerHeader()
            Spacer()
            Divider()
                
            stickerList()
        }
        .onAppear{
            Task{
                await GetSticker()
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
        
        HStack{
            Button(action: {
                
            }){
                HStack{
                    Spacer()
                    Text("Add")
                        .font(.system(size:14))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.vertical,15)
                    Spacer()
                }
                .background(Color.green)
                .cornerRadius(10)
                .padding(.horizontal,5)
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
                    }
                }
                .padding(10)
                
                
                
//                LazyVGrid(columns: columns, spacing: 20) {
//                    ForEach(self.resources, id: \.self) { sticker in
//
//                        AsyncImage(url: URL(string: RESOURCES_HOST + "/sticker/" + sticker)!, content: { img in
//                            img
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//
//
//                        }, placeholder: {
//                            ProgressView()
//                        })
//                    }
//                }
//                .padding(10)
            }
        }
      
    }
    
    private func GetSticker() async {
        self.isLoading = true
        let resp = await  ChatAppService.shared.GetStickerGroup(stickerID: info.id)
        switch resp {
        case.success(let data):
            DispatchQueue.main.async {
                self.resources = data.resources_path
                self.isLoading = false
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
}
