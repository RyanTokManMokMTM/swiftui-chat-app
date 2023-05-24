//
//  GroupProfileEditView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 24/4/2023.
//

import SwiftUI
import PhotosUI
struct GroupProfileEditView: View {
    @StateObject private var hub = BenHubState.shared
    @Binding var info : FullGroupInfo?
    let groupName : String
    @State private var name : String = ""
    @FocusState private var isFocus : Bool
    @State private var isSelected : Bool = false
    @State private var selectedItems : PhotosPickerItem? = nil
    var body: some View {
        List{
            HStack{
                Spacer()
                AsyncImage(url: info?.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                        .overlay(alignment:.bottomTrailing) {
                            Menu(content: {
                                Button(action: {
                                    withAnimation{
                                        self.isSelected = true
                                    }
                                }){
                                    Text("selected from album")
                                }
                            }, label: {
                                Image(systemName: "camera")
                                    .imageScale(.small)
                                    .padding(5)
                                    .foregroundColor(.black)
                                    .background(BlurView(style: .systemChromeMaterialLight).clipShape(Circle()))
                            })
        
                        }
                }, placeholder: {
                    ProgressView()
                })
                Spacer()
            }

            
            Section("Group Name"){
                NavigationLink(destination:EditGroupView(info: $info, data: self.groupName, placeHolder: "Enter a group name")){
                    Text(self.groupName)
                        .bold()
                }
            }
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//        }
        .listStyle(.plain)
        .onAppear{
            self.name = groupName
        }
        .photosPicker(isPresented: $isSelected, selection: $selectedItems, photoLibrary: .shared())
        .onChange(of: self.selectedItems) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    Task {
                        await updateGroupAvatar(data: data)
                    }
                }
            }
        }
    }
    
    @MainActor
    private func updateGroupAvatar(data : Data) async {
        if self.info == nil {
            return
        }
        let req = UploadGroupAvatarReq(group_id: self.info!.id)
        let resp = await ChatAppService.shared.UploadGroupAvatar(imgData: data, req: req)
        switch resp {
        case .success(let data):
            self.info?.avatar = data.path
            hub.AlertMessage(sysImg: "checkmark", message: "Updated.")
            //update room too
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: self.info!.uuid)!) {
                room.avatar = data.path
                UserDataModel.shared.manager.save()
            }
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
}

//struct GroupProfileEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupProfileEditView(info: FullGroupInfo(id: 1, uuid: UUID().uuidString, name: "test_group", avatar: "/default7.jpg", members: 1, created_at: UInt(Date.timeIntervalBetween1970AndReferenceDate), is_joined: true, is_owner: true), groupName: "test_group")
//    }
//}


struct EditGroupView: View {
    @Binding var info : FullGroupInfo?
    let data : String
    let placeHolder : String
    @StateObject private var hub = BenHubState.shared
    @State private var text : String = ""
    @FocusState private var isFocus : Bool
    @State private var isEdit : Bool = false
    @Environment(\.presentationMode) var present
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(alignment:.leading){
                
                HStack{
                    Text("Group Name")
                        .bold()
                    Spacer()
                    
                    Text("\(text.count)/\(30)")
                        .foregroundColor(.gray)
                }
                
                .padding(.vertical,5)
                
                
                TextField(placeHolder, text: $text)
                    .submitLabel(.done)
                    .focused($isFocus)
                
                
                Divider()
            }
            .padding()
        }
//        .wait(isLoading: $hub.isWaiting){
//            BenHubLoadingView(message: hub.message)
//        }
//        .alert(isAlert: $hub.isPresented){
//            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
//        }
        .onChange(of: text){ _ in
            if text != data && !self.isEdit {
                isEdit = true
            }
            
            self.text = String(self.text.prefix(32))
            
        }
        .onAppear{
            self.text = data
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action:{
                    Task{
                        await updatGroupName()
                    }
                }){
                    Text("save")
                        .bold()
                    
                }
                .disabled(!isEdit)
                
                
            }
            
        }
       
    }
    
    @MainActor
    private func updatGroupName() async {
        hub.SetWait(message: "Updating...")
        let req = UpdateGroupInfoReq(group_id: self.info!.id, group_name: self.text)
        let resp = await ChatAppService.shared.UpdateGroupInfo(req: req)
        hub.isWaiting = false
        switch resp {
        case .success(_):
            hub.AlertMessage(sysImg: "checkmark", message: "updated.")
            self.info?.name = self.text
            
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: self.info!.uuid)!) {
                room.name = self.text
                UserDataModel.shared.manager.save()
            }
            
            present.wrappedValue.dismiss()
        case .failure(let err):
            hub.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
}

