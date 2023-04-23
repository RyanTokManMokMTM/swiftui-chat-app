//
//  ProfileView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 7/3/2023.
//

import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject private var userModel : UserViewModel
//    @Binding var isShowSetting : Bool
//    @Binding var loginState : Bool
//    var body: some View {
//        VStack{
//
//        }
//
//
////        VStack{
////            Text("Setting")
////                .frame(width:UIScreen.main.bounds.width)
////                .overlay(alignment:.trailing){
////                    Button(action:{
////                        self.isShowSetting = false
////                    }){
////                        Text("Done")
////                            .padding(.horizontal)
////                    }
////                }
////                .padding(.vertical)
////
////            List{
////                HStack{
////                    Spacer()
////                    VStack(spacing:15){
////                        AsyncImage(url: userModel.profile?.AvatarURL ?? URL(string: ""), content: {img in
////                            img
////                                .resizable()
////                                .frame(width: 100,height:100)
////                                .clipShape(Circle())
////                                .overlay(alignment:.bottomTrailing){
////                                    Image(systemName: "camera")
////                                        .padding(5)
////                                        .background(Color(uiColor: UIColor.systemGray6).clipShape(Circle()))
////                                }
////                        }, placeholder: {
////                            ProgressView()
////                                .frame(width: 100,height:100)
////                        })
////
////
////                        Text(userModel.profile?.name ?? "" )
////                            .font(.title2)
////                            .bold()
////                    }
////                    Spacer()
////                }
////                .listRowBackground(Color.clear)
////                .padding(.bottom)
////
//////
//////                Section{
//////                    settingRow(sysImg: "moon.circle.fill", title: "Dark Mode")
//////                }
////
////                Section{
////                    settingRow(sysImg: "arrow.turn.down.left", title: "Logout"){
////
////                        DispatchQueue.main.async {
////                            self.isShowSetting = false
////                            withAnimation{
////                                self.loginState = true
////                            }
////                            Webcoket.shared.disconnect()
////                            UserDefaults.standard.removeObject(forKey: "token")
////
////                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
////                                self.userModel.profile = nil
////                            }
////
////                        }
////                    }
////                }
////
//////                }
////            }
////            .listStyle(.insetGrouped)
////        }
//    }
//
//    @ViewBuilder
//    private func settingRow(sysImg : String,title : String,action: @escaping ()->Void ) -> some View {
//        Button(action:action){
//            HStack{
//                Image(systemName: sysImg)
//                Text(title)
//            }
//            .foregroundColor(.black)
//        }
//
//    }
//
//}
////
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView_new(profile: UserProfile(id: 1, uuid: UUID().uuidString, name: "jackson_tmm", email: "admin@admin.com", avatar: "/default.jpg", cover: "/default6.jpg", status: "Hello...."))
//    }
//}
struct ProfileView: View {
    @EnvironmentObject private var userModel : UserViewModel
    @Binding var isShowSetting : Bool
    @Binding var loginState : Bool
    
    @State private var isEdit : Bool = false
    @State private var isUpdateState : Bool = false
    var body: some View {
        VStack{
            VStack{
                Spacer()
                AsyncImage(url: self.userModel.profile!.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                }, placeholder: {
                    Color.black
                })
                
                VStack(spacing:8){
                    Text(self.userModel.profile!.name)
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    
                    Button(action: {
                        withAnimation{
                            self.isUpdateState = true
                        }
                    }){
                        HStack{
                            Text(self.userModel.profile!.status.isEmpty ? "Enter Status Message" : self.userModel.profile!.status)
                                .lineLimit(1)
                                .font(.system(size:15))
                                .fontWeight(.medium)
                                .foregroundColor(self.userModel.profile!.status.isEmpty ? Color(uiColor: (UIColor.systemGray2)) : .white)
                            
                            Image(systemName: "chevron.right")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    
                   
                }
                //            Spacer()
                HStack{
//                    Spacer()
                    Button(action: {
                        self.isShowSetting = false
                        withAnimation{
                            self.loginState = true
                        }
                        Webcoket.shared.disconnect()
                        UserDefaults.standard.removeObject(forKey: "token")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                            self.userModel.profile = nil
                        }
                    }){
                        VStack(spacing:8){
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .imageScale(.medium)
                                .rotationEffect(.degrees(180))
                                .fontWeight(.medium)
                            Text("Logout")
                                .fontWeight(.medium)
                                .font(.system(size:14))
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation{
                            self.isEdit = true
                        }
                    }){
                        VStack(spacing:8){
                            Image(systemName: "gearshape")
                                .imageScale(.medium)
                                .fontWeight(.medium)
                            Text("Setting")
                            //                            .bold()
                                .fontWeight(.medium)
                                .font(.system(size:14))
                        }
                    }
                    
//                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top,50)
            }
            .frame(width:UIScreen.main.bounds.width / 1.5)
            
        }
        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.bottom,30)
        .foregroundColor(.white)
        .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        .edgesIgnoringSafeArea(.all)
        .overlay(alignment:.topLeading){
            Button(action: {
                withAnimation{
                    self.isShowSetting = false
                }
            }){
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
            .padding(.horizontal)
            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
        }
        .background(
            VStack{
                AsyncImage(url: self.userModel.profile!.CoverURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay{
                            Color.black.opacity(0.4)
                        }
                }, placeholder: {
                    Color.black
                })
            }
                .edgesIgnoringSafeArea(.all)

        )
        .fullScreenCover(isPresented: $isUpdateState){
            StatusMessageEditView(isEditStatusMsg: $isUpdateState, originalMsg: self.userModel.profile!.status)
                .environmentObject(userModel)
        }
        .fullScreenCover(isPresented: $isEdit){
            UserProfileEditView(isEditProfile: $isEdit)
                .environmentObject(userModel)
        }
        
    }
    

    
}
