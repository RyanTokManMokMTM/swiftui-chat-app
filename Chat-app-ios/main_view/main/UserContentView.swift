//
//  UserContentView.swift
//  Chat-app-ios
//
//  Created by Jackson.tmm on 10/3/2023.
//

import SwiftUI

struct UserContentView: View {
    var profile : UserProfile
    @Binding var isFriend : Bool
    var body: some View {
        VStack{
            Info()
                .padding()
        }
        .background(AsyncImage(url: self.profile.CoverURL, content: { img in
            img
                .resizable()
                .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
        }, placeholder: {
            ProgressView()
                .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
        }).overlay{
            BlurView(style: .regular).edgesIgnoringSafeArea(.all)
        })
      
    }
    
    @ViewBuilder
    private func Info() -> some View {
        VStack{
            AsyncImage(url: self.profile.AvatarURL, content: { img in
                img
                    .resizable()
                    .frame(width:120,height:120)
                    .clipShape(Circle())
                
            }, placeholder: {
                ProgressView()
                    .frame(width:120,height:120)
            })
            
            VStack(spacing: 5){
                Text(self.profile.name)
                    .bold()
                    .font(.title3)
                
                Text(self.profile.email)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing:20){
                contentButton(sysImg: self.isFriend ? "message.fill" : "person.fill.badge.plus", btuName: self.isFriend ? "Chat" : "Add"){
                    if isFriend{
                        print("Chat")
                    }else {
                        Task.init{
                            await addFriend()
                        }
                    }
                }
                contentButton(sysImg: "xmark.circle", btuName: self.isFriend ? "Delete":"Block"){
                    
                    if isFriend {
                        Task.init{
                            await deleteFriend()
                        }
                    }else {
                        print("Block")
                    }
                   
                }
//                contentButton(sysImg: "exclamationmark.bubble",btuName: "Report"){
//                    print("test")
//                }
            }
            .padding(.vertical)
            .padding(.top)
            
//            Spacer()
        }
    }
    
    @ViewBuilder
    private func contentButton(sysImg : String,btuName : String, action : @escaping ()->Void) -> some View {
        Button(action:action){
            VStack{
                Image(systemName: sysImg)
                    .imageScale(.large)
                
                Text(btuName)
                    .font(.caption)
            }
            .frame(width: 70,height: 70)
            .background(BlurView(style: .systemMaterialLight).clipShape(Circle()))
            .padding(5)
          
        }
        .buttonStyle(.plain)
    }
    
    
    private func addFriend() async{
        let req = AddFriendReq(user_id: self.profile.id)
        let resp = await ChatAppService.shared.AddFriend(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                self.isFriend = true
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    private func deleteFriend() async{
        let req = DeleteFriendReq(user_id: self.profile.id)
        let resp = await ChatAppService.shared.DeleteFriend(req: req)
        
        switch resp {
        case .success(let data):
            print(data.code)
            DispatchQueue.main.async {
                self.isFriend = false
            }
            break
        case .failure(let err):
            BenHubState.shared.AlertMessage(sysImg: "xmark", message: err.localizedDescription)
            break
        }
    }
    private func blockFriend(){}
}

struct UserContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentView(profile: UserProfile(id: 1, uuid: UUID().uuidString, name: "Jacksontmm", email: "Admin@admin.com", avatar: "/default.jpg", cover: "/cover.jpg"), isFriend: .constant(true))
    }
}
