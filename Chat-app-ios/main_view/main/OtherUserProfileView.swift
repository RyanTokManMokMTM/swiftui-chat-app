//
//  OtherUserProfileView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 23/4/2023.
//

import SwiftUI

struct SearchUserProfileView: View {
    @Binding var result : SearchUserResult
    @StateObject private var hub = BenHubState.shared
    var body: some View {
        VStack{
            VStack{
                Spacer()
                AsyncImage(url: self.result.user_info.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                }, placeholder: {
                    Color.black
                })
                
                VStack(spacing:8){
                    Text(self.result.user_info.name)
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    
            
                    HStack{
                        Text(self.result.user_info.status.isEmpty ? "Not Set" : self.result.user_info.status)
                            .lineLimit(1)
                            .font(.system(size:15))
                            .fontWeight(.medium)
                            .foregroundColor(self.result.user_info.status.isEmpty ? Color(uiColor: (UIColor.systemGray2)) : .white)
                        
                    }
                    
                    
                   
                }
                //            Spacer()
                buttonView()
            }
            .frame(width:UIScreen.main.bounds.width / 1.5)
            
        }
        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.bottom,30)
        .foregroundColor(.white)
        .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        .edgesIgnoringSafeArea(.all)
        .background(
            VStack{
                AsyncImage(url: self.result.user_info.CoverURL, content: { img in
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
        .onAppear{
            //TODO: Update sender info
            if let sender = UserDataModel.shared.findOneSender(uuid: UUID(uuidString: result.user_info.uuid)!) {
                sender.avatar = result.user_info.avatar
                sender.name = result.user_info.name
                UserDataModel.shared.manager.save()
            }
            
            //TODO: Update Active Room Info
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: result.user_info.uuid)!) {
                room.avatar = result.user_info.avatar
                room.name = result.user_info.name
                UserDataModel.shared.manager.save()
            }
        }
        
     
    }
    
    
    
    
    @ViewBuilder
    private func buttonView() -> some View {
        if self.result.is_friend {
            HStack{
//                    Spacer()
                Button(action: {
                    Task {
                        await self.deleteFriend()
                    }
                }){
                    VStack(spacing:8){
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .fontWeight(.medium)
                        Text("Delete")
                            .fontWeight(.medium)
                            .font(.system(size:14))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    
                }){
                    VStack(spacing:8){
                        Image(systemName: "message")
                            .imageScale(.medium)
                            .fontWeight(.medium)
                        Text("Chat")
                            .fontWeight(.medium)
                            .font(.system(size:14))
                    }
                }

            }
            .padding(.horizontal)
            .padding(.top,50)
        }else {
            HStack{
//                    Spacer()
                Button(action: {
                    Task {
                        await self.addFriend()
                    }
                }){
                    VStack(spacing:8){
                        Image(systemName: "plus")
                            .imageScale(.medium)
                            .rotationEffect(.degrees(180))
                            .fontWeight(.medium)
                        Text("Add")
                            .fontWeight(.medium)
                            .font(.system(size:14))
                    }
                }
               

            }
            .padding(.horizontal)
            .padding(.top,50)
        }
        
    }
    
    

    private func addFriend() async{
        let req = AddFriendReq(user_id: self.result.user_info.id)
        let resp = await ChatAppService.shared.AddFriend(req: req)

        switch resp {
        case .success(let data):
            print(data.code)
            hub.AlertMessage(sysImg: "checkmark", message: "Added.")
            DispatchQueue.main.async {
                self.self.result.is_friend = true
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    
    private func deleteFriend() async{
        let req = DeleteFriendReq(user_id: self.result.user_info.id)
        let resp = await ChatAppService.shared.DeleteFriend(req: req)

        switch resp {
        case .success(let data):
            print(data.code)
            hub.AlertMessage(sysImg: "checkmark", message: "Deleted.")
            DispatchQueue.main.async {
                self.self.result.is_friend = false
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    
}

struct OtherUserInfo  {
    let user_info : UserProfile
    var is_friend : Bool
}

struct OtherUserProfileView: View {
    let uuid : String
    @Binding var isShowDetail: Bool
    @State private var result : OtherUserInfo? = nil
    @StateObject private var hub = BenHubState.shared
    var body: some View {
        VStack{
            VStack{
                Spacer()
                AsyncImage(url: self.result?.user_info.AvatarURL, content: { img in
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width:100,height:100)
                        .clipShape(Circle())
                }, placeholder: {
                    Color.black
                })
                
                VStack(spacing:8){
                    Text(self.result?.user_info.name ?? "")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                    
            
                    HStack{
                        if self.result != nil {
                            Text(self.result!.user_info.status.isEmpty ? "Not Set" : self.result!.user_info.status)
                                .lineLimit(1)
                                .font(.system(size:15))
                                .fontWeight(.medium)
                                .foregroundColor(self.result!.user_info.status.isEmpty ? Color(uiColor: (UIColor.systemGray2)) : .white)
                        }
                       
                        
                    }
                    
                    
                   
                }
                //            Spacer()
                buttonView()
            }
            .frame(width:UIScreen.main.bounds.width / 1.5)
            
        }
        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.bottom,30)
        .foregroundColor(.white)
        .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        .edgesIgnoringSafeArea(.all)
//        .overlay(alignment:.topLeading){
//            Button(action: {
//                withAnimation{
//                    isShowDetail = false
//                }
//            }){
//                Image(systemName: "xmark")
//                    .foregroundColor(.white)
//                    .imageScale(.large)
//            }
//            .padding(.horizontal)
//            .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
//        }
        .background(
            VStack{
                AsyncImage(url: self.result?.user_info.CoverURL, content: { img in
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
        .onAppear{
            Task {
                await self.getProfile()
            }
        }
     
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        if self.result != nil {
            if self.result!.is_friend {
                HStack{
    //                    Spacer()
                    Button(action: {
                        Task {
                            await self.deleteFriend()
                        }
                    }){
                        VStack(spacing:8){
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .fontWeight(.medium)
                            Text("Delete")
                                .fontWeight(.medium)
                                .font(.system(size:14))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }){
                        VStack(spacing:8){
                            Image(systemName: "message")
                                .imageScale(.medium)
                                .fontWeight(.medium)
                            Text("Chat")
                                .fontWeight(.medium)
                                .font(.system(size:14))
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.top,50)
            }else {
                HStack{
    //                    Spacer()
                    Button(action: {
                        Task {
                            await self.addFriend()
                        }
                    }){
                        VStack(spacing:8){
                            Image(systemName: "plus")
                                .imageScale(.medium)
                                .rotationEffect(.degrees(180))
                                .fontWeight(.medium)
                            Text("Add")
                                .fontWeight(.medium)
                                .font(.system(size:14))
                        }
                    }
                   

                }
                .padding(.horizontal)
                .padding(.top,50)
            }
        }
        else {
            EmptyView()
        }
        
    }
    
    @MainActor
    private func getProfile() async {
        let req = GetUserProfileReq(user_id: nil, uuid: self.uuid)
        let resp = await ChatAppService.shared.GetUserProfileInfo(req: req)
        switch resp {
        case .success(let data):
            self.result = OtherUserInfo(user_info: data.user_info, is_friend: data.is_friend)
            //TODO: Update sender info
            if let sender = UserDataModel.shared.findOneSender(uuid: UUID(uuidString: data.user_info.uuid)!) {
                sender.avatar =  data.user_info.avatar
                sender.name =  data.user_info.name
                UserDataModel.shared.manager.save()
            }
            
            //TODO: Update Active Room Info
            if let room = UserDataModel.shared.findOneRoom(uuid: UUID(uuidString: data.user_info.uuid)!) {
                room.avatar = data.user_info.avatar
                room.name = data.user_info.name
                UserDataModel.shared.manager.save()
            }
            
        case .failure(let err):
            print(err.localizedDescription)
        }
    }
    

    private func addFriend() async{
//        let req = AddFriendReq(user_id: self.result.user_info.id)
//        let resp = await ChatAppService.shared.AddFriend(req: req)
//
//        switch resp {
//        case .success(let data):
//            print(data.code)
//            hub.AlertMessage(sysImg: "checkmark", message: "Added.")
//            DispatchQueue.main.async {
//                self.self.result.is_friend = true
//            }
//            break
//        case .failure(let err):
//            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
//            break
//        }
    }
    
    private func deleteFriend() async{
//        let req = DeleteFriendReq(user_id: self.result.user_info.id)
//        let resp = await ChatAppService.shared.DeleteFriend(req: req)
//
//        switch resp {
//        case .success(let data):
//            print(data.code)
//            hub.AlertMessage(sysImg: "checkmark", message: "Deleted.")
//            DispatchQueue.main.async {
//                self.self.result.is_friend = false
//            }
//            break
//        case .failure(let err):
//            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
//            break
//        }
    }
    
}
