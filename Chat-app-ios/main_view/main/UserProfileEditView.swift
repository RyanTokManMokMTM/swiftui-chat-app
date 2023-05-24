//
//  UserProfileEditView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/4/2023.
//

import SwiftUI
import PhotosUI
struct UserProfileEditView: View {
    @EnvironmentObject private var userMode : UserViewModel
    @Binding var isEditProfile : Bool
    
    @StateObject private var hub = BenHubState.shared
    @State private var isShowAvatarPhoto = false
    @State private var isShowCoverPhoto = false
    
    @State private var selectedAvatar : PhotosPickerItem? = nil
    @State private var selectedCover : PhotosPickerItem? = nil
    var body: some View {
        NavigationStack{
            VStack{
                cell()
            }
            .navigationTitle("My profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action:{
                        withAnimation{
                            self.isEditProfile = false
                        }
                    }){
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.black)
                    }
                }
            }
            .photosPicker(isPresented: $isShowAvatarPhoto,selection: $selectedAvatar,matching: .images, photoLibrary: .shared())
            .photosPicker(isPresented: $isShowCoverPhoto, selection: $selectedCover, matching: .images,photoLibrary: .shared())
            .onChange(of: self.selectedAvatar){ newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        
                        Task {
                            await self.uploadAvatar(data : data)
                        }
                    }
                }
            }
            .onChange(of: self.selectedCover){ newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                     
                        Task {
                            await self.uploadCover(data: data)
                        }
                    }
                }
            }

        }
        .accentColor(.black)
        .wait(isLoading: $hub.isWaiting){
            BenHubLoadingView(message: hub.message)
        }
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
    private func cell() -> some View {
        List{
            ZStack{
                AsyncImage(url: self.userMode.profile!.CoverURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:UIScreen.main.bounds.width - 20,height:200)
                        .cornerRadius(10)
                        .overlay{
                            Color.black.opacity(0.4).cornerRadius(10)
                        }
                        .overlay(alignment:.bottomTrailing){
                            Menu(content: {
                                Button(action: {
                                    withAnimation{
                                        self.isShowCoverPhoto = true
                                    }
                                }){
                                    Text("Select from photo album")
                                }
                                
                            }, label: {
                                Label(title: {
                                    Text("")
                                }, icon: {
                                    Image(systemName: "camera.fill")
                                        .imageScale(.small)
                                        .foregroundColor(Color.white)
                                        .padding(5)
                                        .background(BlurView().clipShape(Circle()))
                                })
                            })
                            .padding(5)
                            
                        }
                }, placeholder: {
                    ProgressView()
                        .frame(width:UIScreen.main.bounds.width - 20,height:200)
                    
                })
                
                AsyncImage(url: self.userMode.profile!.AvatarURL, content: { avatar in
                    avatar
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:120,height:120)
                        .clipShape(Circle())
                        .overlay(alignment:.bottomTrailing){
                            Menu(content: {
                                Button(action: {
                                    withAnimation{
                                        self.isShowAvatarPhoto = true
                                    }
                                }){
                                    Text("Select from photo album")
                                }
                                
                            }, label: {
                                Label(title: {
                                    Text("")
                                }, icon: {
                                    Image(systemName: "camera.fill")
                                        .imageScale(.small)
                                        .foregroundColor(Color.white)
                                        .padding(5)
                                        .background(BlurView().clipShape(Circle()))
                                })
                            })
//                            .padding(5)
                        }
                }, placeholder: {
                    
                })
            }
            
            Section("Display Name"){
                NavigationLink(destination: EditView(data: self.userMode.profile!.name, placeHolder: "User Name",editType: .name)
                ){
                    Text(self.userMode.profile!.name)
                        .bold()
                }
            }
            
            Section("Email"){
                Text(self.userMode.profile!.email)
                    .bold()
                    .foregroundColor(.gray)
            }
            
            Section("Status Message"){
                NavigationLink(destination: EditView(data: self.userMode.profile!.status, placeHolder: "Status Message",editType: .status)){
                    Text(self.userMode.profile!.status.isEmpty ? "Not Set" : self.userMode.profile!.status)
                        .bold()
                        .foregroundColor(self.userMode.profile!.status.isEmpty ? .gray : .black)
                }
               
            }
            
    
        }
        .listStyle(.plain)
  
        
    }
    
    
    private func uploadAvatar(data : Data) async {
        hub.SetWait(message: "Uploading...")
        let resp = await ChatAppService.shared.UploadUserAvatar(imgData: data)
        hub.isWaiting = false
        switch resp {
        case .success(let data):
            print(data.code)
            hub.AlertMessage(sysImg: "checkmark", message: "updated.")
            DispatchQueue.main.async {
                self.userMode.profile!.avatar = data.path
                
            }
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            print(err.localizedDescription)
        }
    }
    
    private func uploadCover(data : Data) async {
        hub.SetWait(message: "Uploading...")
        let resp = await ChatAppService.shared.UploadUserCover(imgData: data)
        hub.isWaiting = false
        switch resp {
        case .success(let data):
            print(data.code)
            hub.AlertMessage(sysImg: "checkmark", message: "updated.")
            DispatchQueue.main.async {
                self.userMode.profile!.cover = data.path
                
            }
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            print(err.localizedDescription)
        }
    }
}

