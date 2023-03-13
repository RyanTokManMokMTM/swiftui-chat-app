//
//  ProfileView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @Binding var isShowSetting : Bool
    var body: some View {
        VStack{
            Text("Setting")
                .frame(width:UIScreen.main.bounds.width)
                .overlay(alignment:.trailing){
                    Button(action:{
                        self.isShowSetting = false
                    }){
                        Text("Done")
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            
            List{
                HStack{
                    Spacer()
                    VStack(spacing:15){
                        AsyncImage(url: userModel.profile?.AvatarURL ?? URL(string: ""), content: {img in
                            img
                                .resizable()
                                .frame(width: 100,height:100)
                                .clipShape(Circle())
                                .overlay(alignment:.bottomTrailing){
                                    Image(systemName: "camera")
                                        .padding(5)
                                        .background(Color(uiColor: UIColor.systemGray6).clipShape(Circle()))
                                }
                        }, placeholder: {
                            ProgressView()
                                .frame(width: 100,height:100)
                        })
                        
                        
                        Text(userModel.profile?.name ?? "" )
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .padding(.bottom)
                    
                
                Section{
                    settingRow(sysImg: "moon.circle.fill", title: "Dark Mode")
                }
                
                Section{
                    settingRow(sysImg: "arrow.turn.down.left", title: "Logout")
                }
                
//                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    @ViewBuilder
    private func settingRow(sysImg : String,title : String) -> some View {
        HStack{
            Image(systemName: sysImg)
            Text(title)
        }
    }
    
}
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
