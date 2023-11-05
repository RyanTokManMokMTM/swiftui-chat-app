//
//  StickerListView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/10/2023.
//

import SwiftUI


struct StickerShopView: View {
    @StateObject private var hub = BenHubState.shared
    @EnvironmentObject var stickerShopVM : StickerShopViewModel
    @EnvironmentObject var userVM : UserViewModel
    
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
        .alert(isAlert: $hub.isPresented){
            switch hub.type{
            case .normal,.system:
                BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
            case .messge:
                BenHubAlertWithMessage( message: hub.message,info: hub.info!)
            }
        }
      
        
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
