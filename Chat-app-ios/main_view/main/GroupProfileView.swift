//
//  GroupProfileView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 21/4/2023.
//

import SwiftUI

struct GroupProfileView: View {
    @Binding var info : FullGroupInfo
    @State private var members : [GroupMemberInfo] = []
    var body: some View {
        List{
            GroupHeader()
            
            Section("Members : \(info.members)"){
                ScrollView(.horizontal,showsIndicators: false){
                    HStack{
                        ForEach(members,id:\.id) { member in
                            memberInfo(info: member)
                        }
                    }
                }
                
                
                NavigationLink(destination: ListGourpMemberView(groupID: info.id)){
//                    HStack{
                    Text("view all members")
                        .foregroundColor(.gray)
                }
        
            }
           
        }
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
    
    @ViewBuilder
    private func GroupHeader() -> some View {
        VStack{
            HStack(spacing:12){
                AsyncImage(url: self.info.AvatarURL, content: { img in
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
                    Text(self.info.name)
                        .font(.title2)
                        .bold()
                    Text("\(self.info.uuid)")
                        .font(.footnote)
                        .bold()
                        .lineLimit(1)
                    
                }
                Spacer()
            }
            
            HStack{
                Image(systemName: "timer.circle.fill")
                    .imageScale(.large)
                    .bold()
                
                Text(self.info.CreatedAt.currentDateString(dataStyle: .medium))
                Spacer()
            }
        }
//        .padding(.horizontal)
    }
}

struct OtherGroupProfileView: View {
    let uuid : String
    @Binding var isShowDetail: Bool
    @State private var info : FullGroupInfo? = nil
    @State private var members : [GroupMemberInfo] = []

    var body: some View {
        List{
            GroupHeader()
            
            Section("Members : \(info?.members ?? 0)"){
                ScrollView(.horizontal,showsIndicators: false){
                    HStack{
                        ForEach(members,id:\.id) { member in
                            memberInfo(info: member)
                        }
                    }
                }
                
                
                NavigationLink(destination: ListGourpMemberView(groupID: info?.id ?? 0)){
//                    HStack{
                    Text("view all members")
                        .foregroundColor(.gray)
                }
        
            }
           
        }
        .overlay(alignment:.bottom){
            if self.info != nil {
                if self.info!.is_joined {
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
        }
        .listStyle(.plain)
        .onAppear{
            Task {
                await self.getGroupInfo()
//                await self.getGroupMembers()
            }
        }
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Group Info")
                    .bold()
            }
        }
        
    }
    
    @MainActor
    private func getGroupInfo() async {
        let resp = await ChatAppService.shared.GetGroupInfoByUUID(uuid: self.uuid)
        switch resp {
        case .success(let data):
            self.info = data.result
            Task {
                await self.getGroupMembers(id : data.result.id)
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
    
    @ViewBuilder
    private func GroupHeader() -> some View {
        VStack{
            HStack(spacing:12){
                AsyncImage(url: self.info?.AvatarURL, content: { img in
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
                    Text(self.info?.name ?? "")
                        .font(.title2)
                        .bold()
                    Text("\(self.info?.uuid ?? "")")
                        .font(.footnote)
                        .bold()
                        .lineLimit(1)
                    
                }
                Spacer()
            }
            
            HStack{
                Image(systemName: "timer.circle.fill")
                    .imageScale(.large)
                    .bold()
                
                Text(self.info?.CreatedAt.currentDateString(dataStyle: .medium) ?? "")
                Spacer()
            }
        }
//        .padding(.horizontal)
    }
}
//struct GroupProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupProfileView(info: FullGroupInfo(id: 1, uuid: UUID().uuidString, name: "Test Group", avatar: "/defaultGroup.jpg", members: 10))
//    }
//}
