//
//  CreateGroup.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 12/3/2023.
//

import SwiftUI

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
                    .resizable()                 .frame(width:50,height:50)
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
    @State private var groupName : String = "New Group"
  
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
    }
    
    private func CreateGroup() async{
        if self.groupName.isEmpty {
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: "group name can't be empty!")
            return
        }
        
        let req = CreateGroupReq(group_name: self.groupName)
        let resp = await ChatAppService.shared.CreateGroup(req: req)
        switch resp{
        case .success(let data):
            DispatchQueue.main.async {
                if let room = PersistenceController.shared.CreateUserActiveRoom(id: data.group_uuid, name: self.groupName, avatar: "/defaultGroup.jpg", user_id: Int16(self.userModel.profile!.id), message_type: 2) {
                    
                    withAnimation{
                        self.isShowAddContent = false
                    }
                    NavigationState.shared.navigationRoomPath.append(room)
                }
            }
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
    
    
    @ViewBuilder
    private func GroupHeader() -> some View {
        HStack{
            Image("defaultGroupImg")
                .resizable()
                .frame(width:100,height:100)
                .clipShape(Circle())
                .overlay(alignment:.bottomTrailing){
                    Image(systemName: "camera.circle.fill")
                        .imageScale(.large)
                        .offset(x:-5,y:-5)
                }
            
            TextEditor(text: $groupName)
                .frame(height:80)
                .font(.headline)
        }
        .padding(.horizontal)
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
