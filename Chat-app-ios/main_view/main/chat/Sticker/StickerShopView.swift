//
//  StickerListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import SwiftUI

let temp : [StickerInfo] = [
    StickerInfo(sticker_id: "e58f10c0-46c1-49f8-8133-d5ad6d445b0b", sticker_name: "Sticker A", sticker_thum: "/079ef2e6-fb25-47a5-8f23-8da4efd2d5de/f862fb46-437d-4bd1-97d8-cf9cfdde43dd.png"),
    StickerInfo(sticker_id: "d87b9eb9-8c77-4886-82af-87535f75ed59", sticker_name: "Sticker B", sticker_thum: "/079ef2e6-fb25-47a5-8f23-8da4efd2d5de/f6c8b708-b57b-4008-98a2-2caf114e9a57.png"),
]

struct StickerShopView: View {
    @EnvironmentObject var stickerShopVM : StickerShopViewModel
    
    @Environment(\.presentationMode) var presentation
    var body: some View {
        NavigationStack{
            VStack{
                if self.stickerShopVM.isLoading{
                    HStack{
                        ProgressView()
                        Text("Loading...")
                            .font(.system(size:14))
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding(.horizontal,5)
                    }
                    .padding(.top,25)
                }else {
                    List{
                        ForEach(self.stickerShopVM.stickerList, id :\.id){ info in
                            NavigationLink(value: info) {
                                stickerRow(info: info)
                                    .onTapGesture {
                                        self.stickerShopVM.selectStickerInfoId = info.id
                                    }
                            }
                          
                        }
                    }
                    .listStyle(.plain)
                }
              
            }
            .navigationTitle("Sticker Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action:{
                        presentation.wrappedValue.dismiss()
                    }){
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
            .navigationDestination(for: StickerInfo.self){data in
                AddStickerListView(info: data)
            }
        }
        .accentColor(.green)
      
        
    }
    
    @ViewBuilder
    private func stickerRow(info : StickerInfo) -> some View{
        HStack{
            AsyncImage(url: info.thumURL, content: { img in
                img
                    .resizable()
                    .scaledToFit()
                    .frame(width:45,height: 45)
                    .aspectRatio(contentMode: .fit)
                
                
            }, placeholder: {
                ProgressView()
                    .scaledToFit()
                    .frame(width:45,height: 45)
                    .aspectRatio(contentMode: .fit)
            })
            
            Text(info.sticker_name)
                .font(.system(size:15,weight: .medium))
                .padding(.horizontal)
            Spacer()
        }
    }
}
