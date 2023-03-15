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

    @State private var Friends : [UserProfile] = []
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    NavigationLink(destination: SelectGroupMembers(friends: $Friends,isAddContent: $isAddContent)
                        .environmentObject(userModel))
                    {
                        Label("Create New Group", systemImage: "person.3")
                            .bold()
                            .padding(.vertical,5)
                    }
                    //All Friend Here ??
                    
                    if !self.Friends.isEmpty {
                        ForEach(self.Friends){ data in
                            Button(action:{
                                DispatchQueue.main.async {
                                    CreateActiveRoom(data: data)
                                }
                              
                            }){
                                ContentUserRow(data: data)
                            }
                           
                        }
                    }

                }
                .listStyle(.plain)
                .navigationBarTitle("Add Content",displayMode: .inline)
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
//                                .bold()
                        }
                        
                    }

                }
            }
//            .sheet(isPresented: $isCreateGroup){
//                Text("Create Group")
//            }
        }
        .onAppear{
            Task.init{
                await getFriendsList()
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
            self.Friends = data.friends
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
    
    private func CreateActiveRoom(data : UserProfile){
        
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
    

}

struct AddContent_Previews: PreviewProvider {
    static var previews: some View {
        AddContent(isAddContent: .constant(true))
    }
}
