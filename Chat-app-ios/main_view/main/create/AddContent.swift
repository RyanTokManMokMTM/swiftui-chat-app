//
//  AddContent.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 11/3/2023.
//

import SwiftUI
import CoreData



struct AddContent: View {
    @EnvironmentObject private var userModel : UserViewModel
    @EnvironmentObject private var UDM : UserDataModel
    @StateObject var hub = BenHubState.shared
    @Binding var isAddContent : Bool

    @State private var friends : [UserProfile] = []
    @State private var group : [GroupInfo] = []
    
    @State private var tab : Int = 0
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    NavigationLink(destination: SelectGroupMembers(friends: $friends,isAddContent: $isAddContent)
                        .environmentObject(userModel))
                    {
                        
                        Label{
                            Text("Create a new group")
                                .padding(.vertical,5)
                        } icon: {
                            Image(systemName: "message")
                                .foregroundColor(.green)
                        }
                        .bold()
                    }
             
                    
                    
                    //Joined by gourp ID???
                    NavigationLink(destination: GroupSearchView()
                        .environmentObject(userModel))
                    {
                        Label{
                            Text("Join a group")
                                .padding(.vertical,5)
                        } icon: {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.green)
                        }
                        .bold()

                    }

                    Picker("", selection: $tab){
                        Text("Friends")
                            .bold()
                            .tag(0)
                        
                        Text("Groups")
                            .tag(1)
                            .bold()
                        
                    }.pickerStyle(.segmented)
                        .padding(.horizontal)
                    
                    switch self.tab{
                    case 0:
                        if !self.friends.isEmpty {
                            ForEach(self.friends){ data in
                                Button(action:{
                                    DispatchQueue.main.async {
                                        CreateActiveRoomUser(data: data)
                                    }
                                  
                                }){
                                    ContentUserRow(data: data)
                                }
                               
                            }
                        }else {
                            Text("No Friends")
                        }
                    case 1:
                        if !self.group.isEmpty {
                            ForEach(self.group){ data in
                                Button(action:{
                                    DispatchQueue.main.async {
                                        CreateActiveRoomGroup(data: data)
                                    }
                                  
                                }){
                                    ContentGroupRow(data: data)
                                }
                               
                            }
                        }else {
                            Text("No Group")
                        }
                    default:
                        Text("empty")
                    }
                    

                }
                .listStyle(.plain)
                .navigationBarTitle("Add Content",displayMode: .inline)
                .accentColor(.green)
                .toolbar{
                    ToolbarItem(placement: .principal){
                        Text("Add Content")
                            .bold()
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading){
                        Button(action:{
                            withAnimation{
//                                self.isShowMenu = true
                                self.isAddContent = false
                            }
                        }){
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                                .foregroundColor(.green)
//                                .bold()
                        }
                        
                    }

                }
            }
//            .sheet(isPresented: $isCreateGroup){
//                Text("Create Group")
//            }
        }
        .accentColor(.green)
        .onAppear{
            Task.init{
                await getFriendsList()
                await getGroupList()
            }
        }
        .alert(isAlert: $hub.isPresented){
            BenHubAlertView(message: hub.message, sysImg: hub.sysImg)
        }
    }
    
    private func getFriendsList() async {
        let resp = await ChatAppService.shared.GetFriendList()
        switch resp {
        case .success(let data):
            self.friends = data.friends
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
    private func getGroupList() async {
        let resp = await ChatAppService.shared.GetUserGroups()
        switch resp {
        case .success(let data):
            self.group = data.groups
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func ContentUserRow(data : UserProfile) -> some View {
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
//        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func ContentGroupRow(data : GroupInfo) -> some View {
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
//        .padding(.horizontal)
    }
    
    private func CreateActiveRoomUser(data : UserProfile){
        
        if let room = UDM.findOneRoom(uuid: UUID(uuidString: data.uuid)!){
            print("room is stored")
            self.isAddContent = false
            NavigationState.shared.navigationRoomPath.append(room)
            return
        }

        if let room = UDM.addRoom(id: data.uuid, name: data.name, avatar: data.avatar, message_type: 1) {
            self.isAddContent = false
            
            NavigationState.shared.navigationRoomPath.append(room)
        }

        
    }
    
    private func CreateActiveRoomGroup(data : GroupInfo){
        
        if let room = UDM.findOneRoom(uuid: UUID(uuidString: data.uuid)!){
            print("room is stored")
            self.isAddContent = false
            NavigationState.shared.navigationRoomPath.append(room)
            return
        }

        if let room = UDM.addRoom(id: data.uuid, name: data.name, avatar: data.avatar, message_type: 2) {
            self.isAddContent = false
            NavigationState.shared.navigationRoomPath.append(room)
        }

        
    }
    

}

struct AddContent_Previews: PreviewProvider {
    static var previews: some View {
        AddContent(isAddContent: .constant(true))
    }
}
