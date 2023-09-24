//
//  GroupProfileView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/4/2023.
//

import SwiftUI

struct SearchGroupProfileResultView: View {
    @Binding var info : FullGroupInfo
    @State private var members : [GroupMemberInfo] = []
    @EnvironmentObject private var userVM : UserViewModel
    var body: some View {
        List{
            Section{
                HStack{
                    AsyncImage(url: info.AvatarURL, content: { img in
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:40,height: 40)
                            .clipShape(Circle())
                    }, placeholder: {
                        ProgressView()
                            .frame(width:40,height: 40)
                    })
                    
                    VStack(alignment:.leading,spacing: 2){
                        Text(info.name)
                            .font(.system(size: 18))
                            .bold()
                        
                        Text(info.desc.isEmpty ? "Leader not yet set...d" : info.desc)
                            .font(.footnote)
                            .lineLimit(1)
                        
                    }
                }
            }
                             
            
            Section{
                VStack(spacing:5){
                    
                    NavigationLink(
                        destination:
                            ListGourpMemberView(groupID: info.id)
                                .environmentObject(userVM)
                    ){
                        //                    HStack{
                        HStack{
                            Text("Members")
                                .bold()
                                .font(.system(size:16))
                            Spacer()
                            
                            Text("View \(info.members) members")
                                .foregroundColor(.gray)
                                .font(.system(size:14))
                        }
                    }
                    .padding(.bottom,5)
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack{
                            ForEach(members,id:\.id) { member in
                                memberInfo(info: member)
                            }
                        }
                    }
                    
                }
            }
            
            Section("Group Information"){
                HStack{
                    Text("Name")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info.name)
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Creator")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info.created_by)
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Created At")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info.CreatedAt.dateDescriptiveString(dataStyle: .short))
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Description")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info.desc.isEmpty ? "Not set" : info.desc)
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                    
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay(alignment:.bottom){
            if self.info.is_joined {
//                HStack{
                    VStack{
                        Button(action:{
                            Task {
                                await self.leaveGroup()
                            }
                        }){
                            Text("Leave")
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width - 30,height: 50)
                                .background(Color.red.cornerRadius(10))
                                .padding(.bottom,2)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width,height: 80)
                    .background(Color.white.edgesIgnoringSafeArea(.bottom).shadow(radius: 1))
//                }
            }else {
                VStack{
                    Button(action:{
                        Task {
                            await self.joinGroup()
                        }
                    }){
                        Text("Join")
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 30,height: 50)
                            .background(Color.blue.cornerRadius(10))
                            .padding(.bottom,2)
                    }
                }
                .frame(width: UIScreen.main.bounds.width,height: 80)
                .background(Color.white.edgesIgnoringSafeArea(.bottom).shadow(radius: 1))

            }



        }
        .listStyle(.plain)
        .onAppear{
            Task {
                await self.getGroupMembers()
            }
            //TODO: Update Active Room Info
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: info.uuid)!) {
                room.avatar = info.avatar
                room.name = info.name
                UserDataModel.shared.manager.save()
            }
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Group Info")
                    .bold()
            }
            
        
        }
        
    }
    
    
    private func getGroupMembers() async {
        let req = GetGroupMemberReq(group_id: info.id)
        let resp = await ChatAppService.shared.GetGroupMembers(req: req)
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.members = data.member_list
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func joinGroup() async {
        let req = JoinGroupReq(group_id: self.info.id)
        let resp = await ChatAppService.shared.JoinGroup(req: req)
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                withAnimation{
                    self.info.is_joined = true
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    private func leaveGroup() async {
        let req = LeaveGroupReq(group_id: self.info.id)
        let resp = await ChatAppService.shared.LeaveGroup(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                withAnimation{
                    self.info.is_joined = false
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func memberInfo(info : GroupMemberInfo) -> some View {
        AsyncImage(url: info.AvatarURL, content: { img in
            img
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:50,height:50)
                .clipShape(Circle())

        },placeholder: {
          ProgressView()
                .frame(width:50,height:50)
        })
    }

}

struct GroupProfileView: View {
    let uuid : String
    @Binding var isShowDetail: Bool
    @State private var info : FullGroupInfo? = nil
    @State private var members : [GroupMemberInfo] = []
    @EnvironmentObject private var userModel : UserViewModel
    var body: some View {
        List{
            Section{
                HStack{
                    AsyncImage(url: info?.AvatarURL, content: { img in
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width:40,height: 40)
                            .clipShape(Circle())
                    }, placeholder: {
                        ProgressView()
                            .frame(width:40,height: 40)
                    })
                    
                    VStack(alignment:.leading,spacing: 2){
                        Text(info?.name ?? "--")
                            .font(.system(size: 18))
                            .bold()
                        
                        if let info = info {
                            Text(info.desc.isEmpty ? "Leader not yet set...d" : info.desc)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                        
                    }
                }
            }
                             
            
            Section{
                VStack(spacing:5){
                    
                    NavigationLink(
                        destination:
                            ListGourpMemberView(groupID: info?.id ?? 0)
                            .environmentObject(userModel)
                    ){
                        //                    HStack{
                        HStack{
                            Text("Members")
                                .bold()
                                .font(.system(size:16))
                            Spacer()
                            
                            Text("View \(info?.members ?? 0) members")
                                .foregroundColor(.gray)
                                .font(.system(size:14))
                        }
                    }
                    .padding(.bottom,5)
                    
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack{
                            ForEach(members,id:\.id) { member in
                                memberInfo(info: member)
                            }
                        }
                    }
                    
                }
            }
            
            Section("Group Information"){
                HStack{
                    Text("Name")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info?.name ?? "--")
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Creator")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info?.created_by ?? "--")
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Created At")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    Text(info?.CreatedAt.dateDescriptiveString(dataStyle: .short) ?? "--")
                        .foregroundColor(.gray)
                        .font(.system(size:13))
                }
                
                HStack{
                    Text("Description")
                        .font(.system(size:15))
                        .fontWeight(.medium)
                    Spacer()
                    if let info = self.info {
                        Text(info.desc.isEmpty ? "Not set" : info.desc)
                            .foregroundColor(.gray)
                            .font(.system(size:13))
                    }
                    
                }
            }
            
            Section{
                Text("Clear all history messages")
            }
            
            Section{
                HStack(){
                    Spacer()
                    if self.info != nil {
                        if self.info!.is_joined {
                            Button(action:{
                                Task {
                                    await self.leaveGroup()
                                }
                            }){
                                Text("Leave the group")
                                    .foregroundColor(.red)
                            }
                        }
                        else {
                            Button(action:{
                                Task {
                                    await self.joinGroup()
                                }
                            }){
                                Text("Join the group")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    Spacer()
                }
//                .padding(8)
            }
            
        }
        .listStyle(.insetGrouped)
        .onAppear{
            Task {
                if self.info == nil {
                    await self.getGroupInfo()
                }

            }
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Group Info")
                    .bold()
            }
            
            if info != nil && info!.is_owner{
                ToolbarItem(placement: .navigationBarTrailing){
                    NavigationLink(destination: GroupProfileEditView(info: $info)){
                        Text("Edit")
                            .bold()
                    }
                    
                }
            }
            
        }
        
    }
    
    @MainActor
    private func getGroupInfo() async {
        print(self.uuid)
        let resp = await ChatAppService.shared.GetGroupInfoByUUID(uuid: self.uuid)
        switch resp {
        case .success(let data):
            self.info = data.result
            Task {
                await self.getGroupMembers(id : data.result.id)
            }
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: data.result.uuid)!) {
                room.avatar = data.result.avatar
                room.name = data.result.name
                UserDataModel.shared.manager.save()
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func getGroupMembers(id : UInt) async {
        let req = GetGroupMemberReq(group_id: id)
        let resp = await ChatAppService.shared.GetGroupMembers(req: req)
        switch resp {
        case .success(let data):
            DispatchQueue.main.async {
                self.members = data.member_list
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    private func joinGroup() async {
        let req = JoinGroupReq(group_id: self.info!.id)
        let resp = await ChatAppService.shared.JoinGroup(req: req)
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                withAnimation{
                    self.info!.is_joined = true
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    private func leaveGroup() async {
        let req = LeaveGroupReq(group_id: self.info!.id)
        let resp = await ChatAppService.shared.LeaveGroup(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                withAnimation{
                    self.info!.is_joined = false
                }
            }
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    
    @ViewBuilder
    private func memberInfo(info : GroupMemberInfo) -> some View {
        VStack(spacing:2){
            AsyncImage(url: info.AvatarURL, content: { img in
                img
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:50,height:50)
                    .clipShape(Circle())

            },placeholder: {
              ProgressView()
                    .frame(width:50,height:50)
            })
            Text(info.name)
                .font(.footnote)
                .lineLimit(1)
        }
        .frame(width: 70)
       
    }
    
//    @ViewBuilder
//    private func GroupHeader() -> some View {
//        VStack{
//            HStack(spacing:12){
//                AsyncImage(url: self.info?.AvatarURL, content: { img in
//                    img
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width:80,height: 80)
//                        .clipShape(Circle())
//                }, placeholder: {
//                    ProgressView()
//                        .frame(width:80,height: 80)
//                })
//
//                VStack(alignment:.leading,spacing: 5){
//                    Text(self.info?.name ?? "")
//                        .font(.title2)
//                        .bold()
//                    Text("Created by \(self.info?.created_by ?? "--")")
//                        .font(.footnote)
//                        .bold()
//                        .lineLimit(1)
//
//                }
//                Spacer()
//            }
//        }
////        .padding(.horizontal)
//    }
}
//struct GroupProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupProfileView(info: FullGroupInfo(id: 1, uuid: UUID().uuidString, name: "Test Group", avatar: "/defaultGroup.jpg", members: 10))
//    }
//}

struct GroupHeader : View {
    var avatar : URL?
    var name : String
    var createdBy : String
    var body : some View{
        VStack{
            HStack(spacing:12){
                AsyncImage(url: avatar, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:80,height: 80)
                        .clipShape(Circle())
                }, placeholder: {
                    ProgressView()
                        .frame(width:80,height: 80)
                })
                
                VStack(alignment:.leading,spacing: 5){
                    Text(name)
                        .font(.title2)
                        .bold()
//                    Text("Created by \(createdBy)")
//                        .font(.footnote)
//                        .bold()
//                        .lineLimit(1)
                    
                }
                Spacer()
            }
        }
    }
}
