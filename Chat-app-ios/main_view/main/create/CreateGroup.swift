//
//  CreateGroup.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/3/2023.
//

import SwiftUI
import PhotosUI

struct SelectGroupMembers: View {
    @EnvironmentObject private var userModel : UserViewModel
    @StateObject private var groupVM : GroupViewModel = GroupViewModel()
    @Binding var friends : [UserProfile]
    @Binding var isAddContent : Bool
    var body: some View {
        VStack{
            if !groupVM.members.isEmpty {
                ScrollView(.horizontal,showsIndicators: false){
                    HStack{
                        ForEach(self.groupVM.members){data in
                            GroupMemberCell(data: data)
                                .padding(.horizontal,5)
                               
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            HStack{
                Text("Friends: \(self.friends.count)")
                    .bold()
                    .padding(8)
                
                Spacer()
            }
            .padding(.horizontal)
            List{
               
                ForEach(self.friends){ data in
                    Button(action:{
                        DispatchQueue.main.async {
                            withAnimation{
                                self.groupVM.UpdateGroupMember(info: data)
                                print(data.id)
                            }
                        }
                    }){
                        FriendRow(data: data)
                            
                    }
                   
                    
                }
            }
            .listStyle(.plain)
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Select Friends")
                    .bold()
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink(destination: CreateGroup(isShowAddContent: $isAddContent)
                    .environmentObject(groupVM)
                    .environmentObject(userModel)
                ){
                    Text("Next")
                        .font(.headline)
                        .bold()
                }
               
                
                
            }
        }
    }
    
    @ViewBuilder
    private func GroupMemberCell(data : UserProfile) -> some View{
        VStack{
            AsyncImage(url: data.AvatarURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:50,height:50)
                    .clipShape(Circle())
                    .overlay(alignment:.topTrailing){
                        Image(systemName: "xmark")
                            .imageScale(.small)
                            .padding(5)
                            .foregroundColor(.white)
                            .background(BlurView(style: .systemMaterialDark).clipShape(Circle()))
                            .onTapGesture {
                                print("remove \(data.id)")
                                DispatchQueue.main.async {
                                    withAnimation{
                                        self.groupVM.DeleteSelectedMember(info: data)
                                    }
                             
                                }
                            }
                            
                    }
            }, placeholder: {
                ProgressView()
                    .frame(width:50,height:50)
            })
            
            Text(data.name)
                .font(.subheadline)
                .lineLimit(1)
        }
        .frame(width:60)
        
    }
    
    @ViewBuilder
    private func FriendRow(data : UserProfile) -> some View {
        HStack{
            AsyncImage(url: data.AvatarURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:50,height:50)
                    .clipShape(Circle())
            }, placeholder: {
                ProgressView()
                    .frame(width:50,height:50)
            })
            
            Text(data.name)
                .bold()
                .font(.headline)
            
        }
    }
}

struct CreateGroup : View {
    @Binding var isShowAddContent : Bool
    @EnvironmentObject private var groupVM : GroupViewModel
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @State private var groupName : String = "New Group Name"
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedData : Data? = nil
    var body: some View {
        VStack(spacing:15){

            GroupHeader()
            GroupBody()
            Spacer()
        }
        .padding(.vertical)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Set up group profile")
                    .bold()
//                                    .foregroundColor()
            }
            
            ToolbarItem(placement: .navigationBarTrailing){
                
                Button(action:{
                    print("send request to create...")
                    Task.init{
                        await CreateGroup()
                    }
                }){
                    Text("Create")
                        .font(.headline)
                        .bold()
                }
            }
        }
        .onChange(of: self.selectedItem){ newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    self.selectedData = data
                }
            }
        }
       
        
    }
    
    private func fileBase64Encoding(data : Data,format : String) -> String {
        let base64 = data.base64EncodedString()
        return "data:image/\(format);base64,\(base64)"
    }
    
    private func CreateGroup() async{
        if self.groupName.isEmpty {
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: "group name can't be empty!")
            return
        }
        
        var members : [UInt] = []
        var avatarBase64 : String = ""
        self.groupVM.members.forEach{members.append($0.id)}
        print(members)
        
        if self.selectedData != nil {
            //MARK: encoding image to base64
            avatarBase64 = fileBase64Encoding(data: self.selectedData!, format: "jpg")
        }
        
        
        let req = CreateGroupReq(group_name: self.groupName,members: members,avatar: avatarBase64)
        let resp = await ChatAppService.shared.CreateGroup(req: req)
        switch resp{
        case .success(let data):
            if let room = UDM.addRoom(id: data.group_uuid, name: self.groupName, avatar: data.grou_avatar, message_type: 2) {
                
                withAnimation{
                    self.isShowAddContent = false
                }
                NavigationState.shared.navigationRoomPath.append(room)
            }
            
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func GroupHeader() -> some View {
        HStack{
            imageView()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:100,height:100)
                .clipShape(Circle())
                .overlay(alignment:.bottomTrailing){
                    PhotosPicker(selection: $selectedItem, matching: .any(of: [.images]),photoLibrary: .shared()){
                        VStack{
                            Image(systemName: "camera.fill")
                                .imageScale(.small)
                                .foregroundColor(.black)
                                .padding(5)
                        }
                        .clipShape(Circle())
                        .background(Color.white.clipShape(Circle()))
                        .offset(x:-5,y:-5)
                            
                    }
                  
                }
 
            
            TextEditor(text: $groupName)
                .frame(height:80)
                .font(.headline)
        }
        .padding(.horizontal)
    }
    
    private func imageView() -> Image {
        if self.selectedData == nil {
            return Image("defaultGroupImg")
        }else {
            return Image(uiImage: UIImage(data: self.selectedData!)!)
        }
    }
    
    @ViewBuilder
    private func GroupBody() -> some View {
        VStack(alignment:.leading,spacing: 12){
            Text("Members: \(groupVM.members.count)")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal,showsIndicators: false){
                HStack{
                    ForEach(groupVM.members){ data in
                        memberRow(data: data)
                            .padding(.horizontal,8)
                    }
                }
                .padding(.horizontal)
            }
            
        }
        
    }
    
    @ViewBuilder
    private func memberRow(data : UserProfile) -> some View {
        HStack{
            AsyncImage(url: data.AvatarURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:60,height:60)
                    .clipShape(Circle())
            }, placeholder: {
                ProgressView()
                    .frame(width:50,height:50)
            })
        }
    }
}
//
//struct CreateGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectGroupMembers(friends: .constant([]))
//    }
//}
