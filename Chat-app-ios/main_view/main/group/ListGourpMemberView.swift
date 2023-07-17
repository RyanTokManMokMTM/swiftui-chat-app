//
//  ListGourpMemberView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 22/4/2023.
//

import SwiftUI

struct ListGourpMemberView: View {
    let groupID : UInt
    @State private var members : [GroupMemberInfo] = []
    @State private var viewUserProfile : Bool = true
    @EnvironmentObject private var userModel : UserViewModel
    var body: some View {
        List (){
            ForEach(self.members,id:\.id){ info in
                memberRow(data: info) //view user profile???
            }
        }
        .listStyle(.plain)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Members")
                    .bold()
            }
        }
        .onAppear{
            Task {
                await getMembersInfo()
            }
        }
    }
    
    private func getMembersInfo() async {
        let req = GetGroupMemberReq(group_id: groupID)
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
    
    @ViewBuilder
    private func memberRow(data : GroupMemberInfo) -> some View {
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
            
            HStack{
                Text(data.name)
                    .bold()
                    .font(.headline)
                
                if data.is_group_lead {
                    Text("Owner")
                        .font(.footnote)
                        .padding(5)
                        .background(BlurView(style: .systemMaterialLight).cornerRadius(5))
                }
                
                Spacer()
                
//                if data.is_group_lead && data.uuid != userModel.profile?.uuid {
//                    Button(action:{
//                        //To remove your ...
//                        print("to remove user...")
//                    }){
//                        //Can be remove....
//                        Image(systemName: "xmark")
//                            .imageScale(.medium)
//                            .fontWeight(.bold)
//                            .foregroundColor(.red)
//                            .padding(8)
//                            .background(BlurView(style: .systemMaterialLight).clipShape(Circle()))
//                    }
//                }
                
            }
            
            
        }
    }
}

struct ListGourpMemberView_Previews: PreviewProvider {
    static var previews: some View {
        ListGourpMemberView(groupID: 1)
    }
}
